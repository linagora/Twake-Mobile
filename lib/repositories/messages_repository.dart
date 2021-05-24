import 'dart:async';

import 'package:twake/models/account/account.dart';
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

  Stream<Message> send({
    required String channelId,
    required List<dynamic> prepared,
    String? originalStr,
    String? threadId,
  }) async* {
    if (!Globals.instance.isNetworkConnected) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fakeId = now.toString(); // Unique ID

    final result = await _storage.first(
      table: Table.account,
      where: 'id = ?',
      whereArgs: [Globals.instance.userId],
    );

    Account currentUser = Account.fromJson(json: result);

    Message message = Message(
      id: fakeId,
      threadId: threadId,
      channelId: channelId,
      userId: Globals.instance.userId!,
      creationDate: now,
      modificationDate: now,
      responsesCount: 0,
      content: MessageContent(originalStr: originalStr, prepared: prepared),
      username: currentUser.username,
      firstname: currentUser.firstname,
      lastname: currentUser.lastname,
      reactions: [],
    );

    yield message;
    final data = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': channelId,
      'thread_id': threadId,
      'original_str': originalStr,
      'prepared': prepared,
    };

    final remoteResult =
        await _api.post(endpoint: Endpoint.messages, data: data);

    message = Message.fromJson(json: remoteResult, jsonify: false);

    _storage.insert(table: Table.message, data: message);

    yield message;
  }

  Future<Message> edit({required Message message}) async {
    // Editing should be disallowed without active internet connection
    if (!Globals.instance.isNetworkConnected) return message;

    final data = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': message.channelId,
      'thread_id': message.threadId,
      'original_str': message.content.originalStr,
      'prepared': message.content.prepared,
    };

    final remoteResult =
        await _api.put(endpoint: Endpoint.messages, data: data);

    message = Message.fromJson(json: remoteResult, jsonify: false);

    _storage.insert(table: Table.message, data: message);

    return message;
  }

  Future<void> delete() async {
    // TODO implement message deletion
  }
}
