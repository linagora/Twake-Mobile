import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class ChannelsRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  final String endpoint;

  ChannelsRepository({this.endpoint: Endpoint.channels});

  Stream<List<Channel>> fetch({
    required String companyId,
    required String workspaceId,
    bool localOnly: false,
  }) async* {
    final lchannels =
        await fetchLocal(companyId: companyId, workspaceId: workspaceId);

    yield lchannels;

    if (!Globals.instance.isNetworkConnected || localOnly) return;

    final rchannels =
        await fetchRemote(companyId: companyId, workspaceId: workspaceId);

    yield rchannels;

    if (lchannels.length != rchannels.length) {
      for (final localChannel in lchannels) {
        if (!rchannels.any((c) => c.id == localChannel.id)) {
          Logger().w('Deleting channel: ${localChannel.name}');
          delete(channel: localChannel, syncRemote: false);
        }
      }
    }
  }

  Future<List<Channel>> fetchLocal({
    required String companyId,
    required String workspaceId,
  }) async {
    final localResult = await this._storage.select(
      table: Table.channel,
      where: 'company_id = ? AND workspace_id = ?',
      whereArgs: [companyId, workspaceId],
    );

    var channels =
        localResult.map((entry) => Channel.fromJson(json: entry)).toList();

    channels.sort((c1, c2) => c2.lastActivity.compareTo(c1.lastActivity));

    return channels;
  }

  Future<List<Channel>> fetchRemote({
    required String companyId,
    required String workspaceId,
  }) async {
    final queryParameters = {'mine': 1};

    if (workspaceId == 'direct') {
      queryParameters['include_users'] = 1;
    }

    final List<dynamic> remoteResult = await _api.get(
      endpoint: sprintf(endpoint, [companyId, workspaceId]),
      queryParameters: queryParameters,
      key: 'resources',
    );

    var channels = remoteResult
        .map((entry) => Channel.fromJson(
              json: entry,
              jsonify: false,
              transform: true,
            ))
        .toList();

    _storage.multiInsert(table: Table.channel, data: channels);

    channels.sort((c1, c2) => c2.lastActivity.compareTo(c1.lastActivity));

    return channels;
  }

  Future<Channel> create({required Channel channel}) async {
    final result = await _api.post(
      endpoint: sprintf(endpoint, [channel.companyId, channel.workspaceId]),
      data: {
        'options': {'members': channel.members},
        'resource': channel.toJson(stringify: false)..remove('id'),
      },
      key: 'resource',
    );

    result['name'] = channel.name;
    result['icon'] = channel.icon;

    final created = Channel.fromJson(
      json: result,
      jsonify: false,
      transform: true,
    );

    _storage.insert(table: Table.channel, data: created);

    return created;
  }

  Future<Channel> edit({required Channel channel}) async {
    final result = await _api.post(
      endpoint: sprintf(endpoint, [channel.companyId, channel.workspaceId]) +
          '/${channel.id}',
      data: {
        'resource': channel.toJson(stringify: false),
      },
      key: 'resource',
    );

    Logger().w('Channel data: ${channel.toJson()}');

    var edited = Channel.fromJson(
      json: result,
      jsonify: false,
      transform: true,
    );

    edited = edited.copyWith(
      lastMessage: channel.lastMessage,
      userLastAccess: channel.userLastAccess,
    );

    _storage.insert(table: Table.channel, data: edited);

    return edited;
  }

  Future<void> delete({required Channel channel, bool syncRemote: true}) async {
    final data = channel.toJson();

    if (syncRemote) await _api.delete(endpoint: endpoint, data: data);

    _storage.delete(
      table: Table.channel,
      where: 'id = ?',
      whereArgs: [channel.id],
    );
  }

  Future<List<Account>> fetchMembers({required Channel channel}) async {
    final List<Account> members = [];

    if (channel.members.isEmpty) {
      final List<dynamic> res = await _api.get(
        endpoint: sprintf(
          Endpoint.channelMembers,
          [channel.companyId, channel.workspaceId, channel.id],
        ),
        queryParameters: {'limit': 1000},
        key: 'resources',
      );
      channel.members.addAll(
        res.where((m) => m['user_id'] != null).map((m) => m['user_id']),
      );
    }

    for (final m in channel.members) {
      final member = await _storage.first(
        table: Table.account,
        where: 'id = ?',
        whereArgs: [m],
      );

      if (member.isEmpty) {
        print('Faulty member: $m');
        continue;
      }

      members.add(Account.fromJson(json: member));
    }

    return members;
  }

  Future<Channel> addMembers({
    required Channel channel,
    required List<String> usersToAdd,
  }) async {
    final futures = usersToAdd.map((u) {
      final Map<String, dynamic> data = {
        'resource': {
          'user_id': u,
          'channel_id': channel.id,
          'type': 'member',
        },
      };
      return _api.post(
        endpoint: sprintf(Endpoint.channelMembers,
            [channel.companyId, channel.workspaceId, channel.id]),
        data: data,
      );
    });

    try {
      await Future.wait(futures);
    } catch (e, ss) {
      Logger().e('ERROR during member addition:\n$e\n$ss');
      return channel;
    }

    channel.members.addAll(usersToAdd);

    _storage.insert(table: Table.channel, data: channel);

    return channel;
  }

  Future<Channel> removeMembers({
    required Channel channel,
    required String userId,
  }) async {
    try {
      await _api.delete(
        endpoint: sprintf(Endpoint.channelMembers,
                [channel.companyId, channel.workspaceId, channel.id]) +
            '/$userId',
        data: const {},
      );
    } catch (e, ss) {
      Logger().e('ERROR during member addition:\n$e\n$ss');
      return channel;
    }

    channel.members.removeWhere((u) => u == userId);

    // _storage.insert(table: Table.channel, data: channel);

    return channel;
  }

  Future<void> saveOne({required Channel channel}) async {
    await _storage.insert(table: Table.channel, data: channel);
  }

  Future<Channel> getChannelLocal({required String channelId}) async {
    final res = await _storage.first(
      table: Table.channel,
      where: 'id = ?',
      whereArgs: [channelId],
    );

    final channel = Channel.fromJson(json: res);

    return channel;
  }

  Future<void> markChannelRead({required Channel channel}) async {
    if (!Globals.instance.isNetworkConnected) return;

    await _api.post(
      endpoint: sprintf(
        Endpoint.channelsRead,
        [channel.companyId, channel.workspaceId, channel.id],
      ),
      data: {
        'value': true,
      },
    );
  }
}
