import 'dart:async';

import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/message/message.dart';

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

    final remoteMessages = await fetchRemote(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
      afterMessageId: messages.isNotEmpty ? messages.last.id : null,
    );

    remoteMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));

    yield remoteMessages;
  }

  Future<List<Message>> fetchLocal({
    required String channelId,
    String? threadId,
  }) async {
    var sql = '''
          SELECT m.*, a.username, a.first_name,
            a.last_name,
            a.picture
          FROM ${Table.message.name} AS m JOIN
              ${Table.account.name} AS a ON a.id = m.user_id
              WHERE m.channel_id = ?''';
    if (threadId == null) {
      sql += ' AND m.thread_id = m.id';
    } else {
      sql += ' AND m.thread_id = ?';
    }
    sql += ' ORDER BY created_at DESC';
    final localResult = await _storage.rawSelect(
      sql: sql,
      args: [channelId, if (threadId != null) threadId],
    );
    final messages =
        localResult.map((entry) => Message.fromJson(entry)).toList();

    messages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));

    return messages;
  }

  Future<List<Message>> fetchRemote({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    String? afterMessageId,
  }) async {
    List<dynamic> remoteResult;
    final queryParameters = <String, dynamic>{
      'emoji': false,
    };

    if (afterMessageId != null) {
      queryParameters['page_token'] = afterMessageId;
      queryParameters['direction'] = 'future';
    }
    if (threadId == null) {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threads, [
          companyId ?? Globals.instance.companyId,
          workspaceId ?? Globals.instance.workspaceId,
          channelId
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      );
    } else {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadMessages, [
          companyId ?? Globals.instance.companyId,
          threadId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      );
    }

    var remoteMessages = remoteResult
        .where((rm) => rm['type'] == 'message' && rm['subtype'] == null)
        .map((entry) => Message.fromJson(
              entry,
              channelId: channelId,
              jsonify: false,
              transform: true,
            ));

    await _storage.multiInsert(table: Table.message, data: remoteMessages);

    return await fetchLocal(channelId: channelId, threadId: threadId);
  }

  Future<List<Message>> fetchBefore({
    required String channelId,
    String? threadId,
    required String beforeMessageId,
  }) async {
    List<dynamic> remoteResult;
    if (threadId == null) {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threads, [
          Globals.instance.companyId,
          Globals.instance.workspaceId,
          channelId
        ]),
        queryParameters: {
          'page_token': beforeMessageId,
          'direction': 'history',
        },
        key: 'resources',
      );
    } else {
      remoteResult = await _api.get(
        endpoint: sprintf(
          Endpoint.threadMessages,
          [Globals.instance.companyId, threadId],
        ),
        queryParameters: {
          'page_token': beforeMessageId,
          'direction': 'history',
        },
        key: 'resources',
      );
    }

    var remoteMessages = remoteResult
        .where((rm) => rm['type'] == 'message' && rm['subtype'] == null)
        .map((entry) => Message.fromJson(
              entry,
              jsonify: false,
              transform: true,
              channelId: channelId,
            ));

    await _storage.multiInsert(table: Table.message, data: remoteMessages);

    return await fetchLocal(channelId: channelId, threadId: threadId);
  }

  Stream<Message> send({
    required String id,
    required String channelId,
    required List<dynamic> prepared,
    String? originalStr,
    required String threadId,
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
      createdAt: now,
      updatedAt: now,
      responsesCount: 0,
      text: originalStr ?? '',
      blocks: [],
      username: currentUser.username,
      firstName: currentUser.firstName,
      lastName: currentUser.lastName,
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
        await _api.post(endpoint: Endpoint.threads, data: data);

    message = Message.fromJson(remoteResult, jsonify: false);
    message.createdAt = now;
    message.updatedAt = now;

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
      'original_str': message.text,
      'prepared': message.blocks,
    };

    final remoteResult = await _api.put(endpoint: Endpoint.threads, data: data);

    message = Message.fromJson(remoteResult, jsonify: false);

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
    await _api.delete(endpoint: Endpoint.threads, data: data);

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
    final sql = '''
          SELECT m.*, a.username, a.first_name,
            a.last_name,
            a.picture
          FROM ${Table.message.name} AS m JOIN
              ${Table.account.name} AS a ON a.id = m.user_id
              WHERE m.id = ?''';
    final result = await _storage.rawSelect(sql: sql, args: [messageId]);

    final message = Message.fromJson(result.first);

    return message;
  }

  Future<Message> getMessageRemote({
    required String messageId,
    required String threadId,
  }) async {
    final remoteResult = await _api.get(
      endpoint: sprintf(
              Endpoint.threadMessages, [Globals.instance.companyId, threadId]) +
          '/$messageId',
      key: 'resource',
    );

    final message = Message.fromJson(
      remoteResult,
      transform: true,
      channelId: Globals.instance.channelId,
    );

    await _storage.insert(table: Table.message, data: message);

    return await getMessageLocal(messageId: messageId);
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
