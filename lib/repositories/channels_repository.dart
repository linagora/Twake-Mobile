import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

abstract class BaseChannelsRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  final String endpoint;

  BaseChannelsRepository({this.endpoint: Endpoint.channels});

  Stream<List<Channel>> fetch({
    String? companyId,
    required String workspaceId,
  }) async* {
    if (companyId == null) companyId = Globals.instance.companyId;

    final localResult = await this._storage.select(
      table: Table.channel,
      where: 'company_id = ? AND workspace_id = ?',
      whereArgs: [companyId, workspaceId],
    );

    var channels =
        localResult.map((entry) => Channel.fromJson(json: entry)).toList();

    channels.sort((c1, c2) => c2.lastActivity.compareTo(c1.lastActivity));
    yield channels;

    if (!Globals.instance.isNetworkConnected) return;

    final queryParameters = {
      'company_id': companyId,
      'workspace_id': workspaceId
    };

    final List<dynamic> remoteResult = await _api.get(
      endpoint: endpoint,
      queryParameters: queryParameters,
    );

    if (remoteResult.length != channels.length) {
      await _storage.truncate(table: Table.channel);
    }

    channels = remoteResult
        .map((entry) => Channel.fromJson(json: entry, jsonify: false))
        .toList();

    _storage.multiInsert(table: Table.channel, data: channels);

    yield channels;
  }

  Future<Channel> create({required Channel channel}) async {
    final result = await _api.post(
      endpoint: endpoint,
      data: channel.toJson(stringify: false),
    );

    final created = Channel.fromJson(json: result, jsonify: false);

    _storage.insert(table: Table.channel, data: created);

    return created;
  }

  Future<Channel> edit({required Channel channel}) async {
    final result = await _api.put(
      endpoint: endpoint,
      data: channel.toJson(stringify: false),
    );

    final edited = Channel.fromJson(json: result, jsonify: false);

    _storage.insert(table: Table.channel, data: edited);

    return edited;
  }

  Future<void> delete({required Channel channel}) async {
    final data = channel.toJson();

    data['channel_id'] = channel.id;

    await _api.delete(endpoint: endpoint, data: data);

    _storage.delete(
      table: Table.channel,
      where: 'id = ?',
      whereArgs: [channel.id],
    );
  }
}
