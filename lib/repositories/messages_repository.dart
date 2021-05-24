import 'dart:async';

import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';

const _LIST_SIZE = 30;

class MessagesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  MessagesRepository();

  Stream<List<Message>> fetch({
    String? companyId,
    String? workspaceId,
    String? channelId,
    String? threadId,
  }) async* {
    final localResult = await this._storage.select(
          table: Table.message,
          where: 'channel_id = ? AND thread_id = ?',
          whereArgs: [channelId, threadId],
          limit: _LIST_SIZE,
        );
    var messages =
        localResult.map((entry) => Message.fromJson(json: entry)).toList();

    messages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));
    yield messages;

    if (!Globals.instance.isNetworkConnected) return;
    final Map<String, dynamic> queryParameters = {
      'company_id': companyId ?? Globals.instance.companyId,
      'workspace_id': workspaceId ?? Globals.instance.workspaceId,
      'channel_id': channelId ?? Globals.instance.channelId,
      'thread_id': threadId,
      'limit': _LIST_SIZE,
    };

    // If messages are present in local storage, just request messages
    // after the last one
    if (messages.isNotEmpty) {
      queryParameters['after_date'] = messages.last.modificationDate;
    }

    final remoteResult = await this._api.get(
          endpoint: Endpoint.messages,
          queryParameters: queryParameters,
        );
    messages = remoteResult
        .map((entry) => Message.fromJson(
              json: entry,
              jsonify: false,
            ))
        .toList();

    yield messages;
  }

  Future<List<Message>> fetchBefore({
    String? channelId,
    String? threadId,
    required String beforeMessageId,
    required int beforeDate,
  }) async {
    final localResult = await this._storage.select(
          table: Table.message,
          where: 'channel_id = ? AND thread_id = ? AND creation_date < ?',
          whereArgs: [channelId, threadId, beforeDate],
          limit: _LIST_SIZE,
        );
    var messages =
        localResult.map((entry) => Message.fromJson(json: entry)).toList();

    messages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));

    if (messages.isNotEmpty) return messages;

    final queryParameters = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': channelId ?? Globals.instance.channelId,
      'thread_id': threadId,
      'limit': _LIST_SIZE,
      'before_message_id': beforeMessageId,
    };

    final remoteResult = await this._api.get(
          endpoint: Endpoint.messages,
          queryParameters: queryParameters,
        );
    messages = remoteResult
        .map((entry) => Message.fromJson(
              json: entry,
              jsonify: false,
            ))
        .toList();

    return messages;
  }
}
