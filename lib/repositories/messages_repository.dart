import 'dart:async';

import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/message/message.dart';

const _LIST_SIZE = 30;

class MessagesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  MessagesRepository();

  Stream<List<Message>> fetch({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
  }) async* {
    var messages = await fetchLocal(channelId: channelId, threadId: threadId);

    yield messages;

    if (!Globals.instance.isNetworkConnected) return;

    // If messages are present in local storage, just request messages
    // after the last one, via after_date query param
    int? afterDate;
    if (messages.isNotEmpty) {
      afterDate = messages.last.modificationDate;
    }

    final remoteMessages = await fetchRemote(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
      afterDate: afterDate,
    );

    if (messages.isNotEmpty) {
      messages.addAll(remoteMessages);
    } else {
      messages = remoteMessages;
    }

    messages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));

    yield messages;
  }

  Future<List<Message>> fetchLocal({
    required String channelId,
    String? threadId,
  }) async {
    final localResult = await _storage.select(
      table: Table.message,
      where: 'channel_id = ? AND thread_id = ?',
      whereArgs: [channelId, threadId],
      limit: _LIST_SIZE,
    );
    final messages =
        localResult.map((entry) => Message.fromJson(json: entry)).toList();

    messages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));

    return messages;
  }

  Future<List<Message>> fetchRemote({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    int? afterDate,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'company_id': companyId ?? Globals.instance.companyId,
      'workspace_id': workspaceId ?? Globals.instance.workspaceId,
      'channel_id': channelId,
      'thread_id': threadId,
      'limit': _LIST_SIZE,
    };

    if (afterDate != null) queryParameters['after_date'] = afterDate;

    final List<dynamic> remoteResult = await _api.get(
      endpoint: Endpoint.messages,
      queryParameters: queryParameters,
    );
    var remoteMessages = remoteResult.map((entry) => Message.fromJson(
          json: entry,
          jsonify: false,
        ));

    _storage.multiInsert(table: Table.message, data: remoteMessages);

    // API returns top level messages intermixed with thread level messages
    // so we need to filter here
    remoteMessages = remoteMessages
        .where((m) => m.channelId == channelId && m.threadId == threadId);

    return remoteMessages.toList();
  }

  Future<List<Message>> fetchBefore({
    String? channelId,
    String? threadId,
    required String beforeMessageId,
    required int beforeDate,
  }) async {
    final localResult = await _storage.select(
      table: Table.message,
      where: 'channel_id = ? AND thread_id = ? AND creation_date < ?',
      whereArgs: [
        channelId ?? Globals.instance.channelId,
        threadId,
        beforeDate,
      ],
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

    final List<dynamic> remoteResult = await _api.get(
      endpoint: Endpoint.messages,
      queryParameters: queryParameters,
    );

    var remoteMessages = remoteResult.map((entry) => Message.fromJson(
          json: entry,
          jsonify: false,
        ));

    _storage.multiInsert(table: Table.message, data: remoteMessages);

    // API returns top level messages intermixed with thread level messages
    // so we need to filter here
    messages = remoteMessages
        .where((m) => m.channelId == channelId && m.threadId == threadId)
        .toList();

    messages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));

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

  Future<Message> react({
    required Message message,
    required String reaction,
  }) async {
    // Reactions should be disallowed without active internet connection
    if (!Globals.instance.isNetworkConnected) return message;

    final data = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': message.channelId,
      'thread_id': message.threadId,
      'message_id': message.id,
      'reaction': reaction,
    };

    // Might add some extra checks
    await _api.post(endpoint: Endpoint.reactions, data: data);

    _storage.insert(table: Table.message, data: message);

    return message;
  }

  Future<void> delete({required String messageId, String? threadId}) async {
    // Deleting should be disallowed without active internet connection
    if (!Globals.instance.isNetworkConnected) return;

    final data = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': Globals.instance.channelId,
      'message_id': messageId,
      'thread_id': threadId,
    };
    await _api.delete(endpoint: Endpoint.messages, data: data);

    // Only delete message from local store if API request was successful
    await _storage.delete(
      table: Table.message,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<Message> getMessageLocal({required String messageId}) async {
    final result = await _storage.first(
      table: Table.message,
      where: 'id = ?',
      whereArgs: [messageId],
    );

    final message = Message.fromJson(json: result);

    return message;
  }

  Future<Message> getMessageRemote({
    required String messageId,
    String? channelId,
    String? threadId,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': channelId ?? Globals.instance.channelId,
      'message_id': messageId,
      'thread_id': threadId,
    };

    final List<dynamic> remoteResult = await _api.get(
      endpoint: Endpoint.messages,
      queryParameters: queryParameters,
    );

    final message = Message.fromJson(json: remoteResult.first);

    _storage.insert(table: Table.message, data: message);

    return message;
  }

  Future<void> removeMessageLocal({required String messageId}) async {
    _storage.delete(
      table: Table.message,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
}
