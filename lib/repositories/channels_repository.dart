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
        if (!rchannels.any((c) => c.id == localChannel.id))
          Logger().v('Deleting channel: ${localChannel.name}');
        delete(channel: localChannel, syncRemote: false);
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
        endpoint:
            sprintf(endpoint, [channel.companyId, channel.workspaceId]) + '/',
        data: {
          'options': {'members': channel.members},
          'resource': channel.toJson(stringify: false),
        });

    final created = Channel.fromJson(json: result, jsonify: false);

    _storage.insert(table: Table.channel, data: created);

    return created;
  }

  Future<Channel> createDirect(
      {String? companyId, required String member}) async {
    final data = {
      'company_id': companyId ?? Globals.instance.companyId,
      'member': member
    };

    final result = await _api.post(
      endpoint: endpoint,
      data: data,
    );

    final created = Channel.fromJson(json: result, jsonify: false);

    _storage.insert(table: Table.channel, data: created);

    return created;
  }

  Future<Channel> edit({required Channel channel}) async {
    final result = await _api.post(
      endpoint: sprintf(endpoint, [channel.companyId, channel.workspaceId]) +
          '/${channel.id}',
      data: channel.toJson(stringify: false),
    );

    final edited =
        Channel.fromJson(json: result, jsonify: false, transform: true);

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
    for (final m in channel.members) {
      final member = await _storage.first(
        table: Table.account,
        where: 'id = ?',
        whereArgs: [m],
      );

      members.add(Account.fromJson(json: member));
    }

    return members;
  }

  Future<Channel> addMembers({
    required Channel channel,
    required List<String> usersToAdd,
  }) async {
    final Map<String, dynamic> data = {
      'company_id': channel.companyId,
      'workspace_id': channel.workspaceId,
      'id': channel.id,
      'members': usersToAdd,
    };

    await _api.post(endpoint: Endpoint.channelMembers, data: data);

    channel.members.addAll(usersToAdd);

    _storage.insert(table: Table.channel, data: channel);

    return channel;
  }

  Future<Channel> removeMembers({
    required Channel channel,
    required List<String> usersToRemove,
  }) async {
    final Map<String, dynamic> data = {
      'company_id': channel.companyId,
      'workspace_id': channel.workspaceId,
      'id': channel.id,
      'members': usersToRemove,
    };
    await _api.delete(endpoint: Endpoint.channelMembers, data: data);

    channel.members.removeWhere((c) => usersToRemove.contains(c));

    _storage.insert(table: Table.channel, data: channel);

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
      endpoint: Endpoint.channelsRead,
      data: {
        'company_id': channel.companyId,
        'workspace_id': channel.workspaceId,
        'id': channel.id,
      },
    );
  }
}
