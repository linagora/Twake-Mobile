import 'dart:async';

import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/message/message.dart';

const _LIST_SIZE = 50;
const _THREAD_SIZE = 1000;

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
    // TODO IMPLEMENT SIMILAR MECHANISM
    // int? afterDate;
    // if (messages.isNotEmpty && threadId == null) {
    // afterDate = messages
    // .fold<Message>(messages.first, (a, b) => a.recent(b))
    // .modificationDate;
    // }

    final remoteMessages = await fetchRemote(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
    );

    // if (messages.isNotEmpty && afterDate != null) {
    // for (final m in remoteMessages) {
    // final index = messages.indexWhere((lm) => lm.id == m.id);
    // if (!index.isNegative) {
    // messages[index] = m;
    // } else {
    // messages.add(m);
    // }
    // }
    // } else {
    // messages = remoteMessages;
    // }
//
    remoteMessages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));

    yield remoteMessages;
  }

  Future<List<Message>> fetchLocal({
    required String channelId,
    String? threadId,
  }) async {
    var where = 'channel_id = ?';
    if (threadId == null) {
      where += ' AND thread_id IS NULL';
    } else {
      where += ' AND thread_id = ?';
    }
    final localResult = await _storage.select(
      table: Table.message,
      where: where,
      orderBy: 'creation_date DESC',
      whereArgs: [channelId, if (threadId != null) threadId],
      limit: threadId != null ? _THREAD_SIZE : _LIST_SIZE,
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
  }) async {
    final Map<String, dynamic> queryParameters = {
      'company_id': companyId ?? Globals.instance.companyId,
      'workspace_id': workspaceId ?? Globals.instance.workspaceId,
      // TODO remove fallback_ws_id after files are fixed
      'fallback_ws_id': Globals.instance.workspaceId,
      'channel_id': channelId,
      'limit': threadId != null ? _THREAD_SIZE : _LIST_SIZE,
    };

    if (threadId != null) queryParameters['thread_id'] = threadId;

    // if (afterDate != null) queryParameters['after_date'] = afterDate;

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
    required String channelId,
    String? threadId,
    required String beforeMessageId,
    required int beforeDate,
  }) async {
    var where = 'channel_id = ? AND creation_date < ?';
    if (threadId == null) {
      where += ' AND thread_id IS NULL';
    } else {
      where += ' AND thread_id = ?';
    }
    final localResult = await _storage.select(
      table: Table.message,
      where: where,
      whereArgs: [
        channelId,
        beforeDate,
        if (threadId != null) threadId,
      ],
      orderBy: 'creation_date DESC',
      limit: _LIST_SIZE,
    );
    var messages =
        localResult.map((entry) => Message.fromJson(json: entry)).toList();

    messages.sort((m1, m2) => m1.creationDate.compareTo(m2.creationDate));

    if (messages.isNotEmpty) return messages;

    final queryParameters = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId,
      'channel_id': channelId,
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
    required String id,
    required String channelId,
    required List<dynamic> prepared,
    String? originalStr,
    String? threadId,
  }) async* {
    if (!Globals.instance.isNetworkConnected) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await _storage.first(
      table: Table.account,
      where: 'id = ?',
      whereArgs: [Globals.instance.userId],
    );

    Account currentUser = Account.fromJson(json: result);

    Message message = Message(
      id: id,
      threadId: threadId,
      channelId: channelId,
      userId: currentUser.id,
      creationDate: now,
      modificationDate: now,
      responsesCount: 0,
      content: MessageContent(originalStr: originalStr, prepared: prepared),
      username: currentUser.username,
      firstname: currentUser.firstname,
      lastname: currentUser.lastname,
      reactions: [],
    );

    message.isDelivered = false;

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
    message.creationDate = now;
    message.modificationDate = now;

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
      'message_id': message.id,
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

  Future<Message> getMessage({required String messageId}) async {
    try {
      return await getMessageLocal(messageId: messageId);
    } catch (_) {
      return await getMessageRemote(messageId: messageId);
    }
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
      // TODO remove fallback_ws_id after files are fixed
      'fallback_ws_id': Globals.instance.workspaceId,
      'message_id': messageId,
    };

    if (threadId?.isNotEmpty ?? false) queryParameters['thread_id'] = threadId;

    final List<dynamic> remoteResult = await _api.get(
      endpoint: Endpoint.messages,
      queryParameters: queryParameters,
    );

    Logger().v('Remote message: $remoteResult');

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

  Future<void> saveOne({required Message message}) async {
    await _storage.insert(table: Table.message, data: message);
  }
}
