import 'dart:async';

import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/api_data_transformer.dart';

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

    if (remoteMessages.isEmpty) return;

    remoteMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));

    yield remoteMessages;
  }

  Future<List<Message>> fetchLocal({
    required String channelId,
    String? threadId,
  }) async {
    // var sql = '''
    // SELECT m.*, a.username, a.first_name,
    // a.last_name,
    // a.picture
    // FROM ${Table.message.name} AS m JOIN
    // ${Table.account.name} AS a ON a.id = m.user_id
    // WHERE m.channel_id = ?''';
    var where = 'channel_id = ?';
    if (threadId == null) {
      where += ' AND thread_id = id';
    } else {
      where += ' AND thread_id = ?';
    }
    final localResult = await _storage.select(
      table: Table.message,
      where: where,
      whereArgs: [channelId, if (threadId != null) threadId],
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
      'include_users': 1,
      'emoji': false,
      'direction': 'history',
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
      queryParameters['limit'] = 1000;

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
    final queryParameters = {
      'include_users': 1,
      'page_token': beforeMessageId,
      'direction': 'history',
    };
    if (threadId == null) {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threads, [
          Globals.instance.companyId,
          Globals.instance.workspaceId,
          channelId
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      );
    } else {
      remoteResult = await _api.get(
        endpoint: sprintf(
          Endpoint.threadMessages,
          [Globals.instance.companyId, threadId],
        ),
        queryParameters: queryParameters,
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
    List<String> files: const [],
    String? originalStr,
    required String threadId,
    bool isDirect: false,
  }) async* {
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
      files: files,
      blocks: prepared,
      username: currentUser.username,
      firstName: currentUser.firstName,
      lastName: currentUser.lastName,
      picture: currentUser.picture,
      reactions: [],
    );

    message.delivery = Delivery.inProgress;

    yield message;

    final data = threadId == id
        ? {
            'resource': {
              'participants': [
                {
                  'type': 'channel',
                  'id': channelId,
                  'workspace_id':
                      isDirect ? 'direct' : Globals.instance.workspaceId,
                  'company_id': Globals.instance.companyId,
                }
              ]
            },
            'options': {
              'message': ApiDataTransformer.apiMessage(message: message)
            }
          }
        : {'resource': ApiDataTransformer.apiMessage(message: message)};

    final endpoint = threadId == id
        ? sprintf(Endpoint.threadsPost, [Globals.instance.companyId])
        : sprintf(
            Endpoint.threadMessages,
            [Globals.instance.companyId, threadId],
          );

    try {
      final remoteResult = await _api.post(
        endpoint: endpoint,
        data: data,
        key: 'resource',
      );
      message = Message.fromJson(
        id == threadId ? remoteResult['message'] : remoteResult,
        jsonify: false,
        transform: true,
        channelId: channelId,
      );
      message.createdAt = now;
      message.updatedAt = now;

      message.username = currentUser.username;
      message.firstName = currentUser.firstName;
      message.lastName = currentUser.lastName;
      message.picture = currentUser.picture;
    } catch (e, ss) {
      Logger().e('Error sending message: $e\n$ss');
      message.delivery = Delivery.failed;
    }

    _storage.insert(table: Table.message, data: message);

    yield message;
  }

  Stream<Message> resend({
    required Message message,
    bool isDirect: false,
  }) async* {
    message.delivery = Delivery.inProgress;
    final now = DateTime.now().millisecondsSinceEpoch;

    yield message;

    final data = message.threadId == message.id
        ? {
            'resource': {
              'participants': [
                {
                  'type': 'channel',
                  'id': message.channelId,
                  'workspace_id':
                      isDirect ? 'direct' : Globals.instance.workspaceId,
                  'company_id': Globals.instance.companyId,
                }
              ]
            },
            'options': {
              'message': ApiDataTransformer.apiMessage(message: message)
            }
          }
        : {'resource': ApiDataTransformer.apiMessage(message: message)};

    final endpoint = message.threadId == message.id
        ? sprintf(Endpoint.threadsPost, [Globals.instance.companyId])
        : sprintf(
            Endpoint.threadMessages,
            [Globals.instance.companyId, message.threadId],
          );

    try {
      final remoteResult = await _api.post(
        endpoint: endpoint,
        data: data,
        key: 'resource',
      );
      final newMessage = Message.fromJson(
        message.id == message.threadId ? remoteResult['message'] : remoteResult,
        jsonify: false,
        transform: true,
        channelId: message.channelId,
      );
      newMessage.createdAt = now;
      newMessage.updatedAt = now;

      newMessage.username = message.username;
      newMessage.firstName = message.firstName;
      newMessage.lastName = message.lastName;
      newMessage.picture = message.picture;

      _storage.delete(
        table: Table.message,
        where: 'id = ?',
        whereArgs: [message.id],
      );

      message = newMessage;
    } catch (e, ss) {
      Logger().e('Error sending message: $e\n$ss');
      message.delivery = Delivery.failed;
    }

    _storage.insert(table: Table.message, data: message);

    yield message;
  }

  Future<Message> edit({required Message message}) async {
    // Editing should be disallowed without active internet connection
    if (!Globals.instance.isNetworkConnected) return message;

    final remoteResult = await _api.post(
      endpoint: sprintf(
            Endpoint.threadMessages,
            [Globals.instance.companyId, message.threadId],
          ) +
          '/${message.id}',
      data: {'resource': ApiDataTransformer.apiMessage(message: message)},
      key: 'resource',
    );

    final edited = Message.fromJson(
      remoteResult,
      jsonify: false,
      transform: true,
      channelId: message.channelId,
    );

    edited.username = message.username;
    edited.firstName = message.firstName;
    edited.lastName = message.lastName;
    edited.picture = message.picture;

    _storage.insert(table: Table.message, data: edited);

    return edited;
  }

  Future<Message> react({
    required Message message,
    required String reaction,
  }) async {
    // Reactions should be disallowed without active internet connection
    if (!Globals.instance.isNetworkConnected) return message;

    // Might add some extra checks
    await _api.post(
        endpoint: sprintf(Endpoint.threadMessages,
                [Globals.instance.companyId, message.threadId]) +
            '/${message.id}/reaction',
        data: {
          'reactions': [reaction]
        });

    _storage.insert(table: Table.message, data: message);

    return message;
  }

  Future<void> delete({
    required String messageId,
    required String threadId,
  }) async {
    // Deleting should be disallowed without active internet connection
    if (!Globals.instance.isNetworkConnected) return;

    await _api.post(
        endpoint: sprintf(
              Endpoint.threadMessages,
              [Globals.instance.companyId, threadId],
            ) +
            '/$messageId/delete',
        data: const {});

    // Only delete message from local store if API request was successful
    await _storage.delete(
      table: Table.message,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<Message> getMessage({
    required String messageId,
    String? threadId,
  }) async {
    try {
      return await getMessageLocal(messageId: messageId);
    } catch (_) {
      return await getMessageRemote(
        messageId: messageId,
        threadId: threadId ?? messageId,
      );
    }
  }

  Future<Message> getMessageLocal({required String messageId}) async {
    final result = await _storage.first(
      table: Table.message,
      where: 'id = ?',
      whereArgs: [messageId],
    );

    final message = Message.fromJson(result);

    return message;
  }

  Future<Message> getMessageRemote({
    required String messageId,
    required String threadId,
  }) async {
    final remoteResult = await _api.get(
      endpoint: sprintf(
            Endpoint.threadMessages,
            [Globals.instance.companyId, threadId],
          ) +
          '/$messageId',
      key: 'resource',
      queryParameters: {'include_users': 1},
    );

    final message = Message.fromJson(
      remoteResult,
      jsonify: false,
      transform: true,
      channelId: Globals.instance.channelId,
    );

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
