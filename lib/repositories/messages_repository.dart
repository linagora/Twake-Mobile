import 'dart:async';

import 'package:mutex/mutex.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/api_data_transformer.dart';

export 'package:twake/models/message/message.dart';

class MessagesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  final Mutex _sendGuard = Mutex();

  int _counter = 0;
  int _turn = 0;

  MessagesRepository();

  Stream<List<Message>> fetch({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
    bool? withExistedFiles = false,
  }) async* {
    var messages = await fetchLocal(
      channelId: channelId,
      threadId: threadId,
      withExistedFiles: withExistedFiles,
    );
    yield messages;

    if (!Globals.instance.isNetworkConnected) return;

    final remoteMessages = await fetchRemote(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
      afterMessageId: messages.isNotEmpty ? messages.last.id : null,
      withExistedFiles: withExistedFiles,
    );

    if (remoteMessages.isEmpty) return;

    remoteMessages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));

    yield remoteMessages;
  }

  Future<List<Message>> fetchLocal({
    required String channelId,
    String? threadId,
    bool? withExistedFiles = false,
  }) async {
    var where = 'channel_id = ?';
    if (threadId == null) {
      where += ' AND thread_id = id';
    } else {
      where += ' AND thread_id = ?';
    }
    if (withExistedFiles == true) {
      where += ' AND files <> ?';
    }
    final localResult = await _storage.select(
      table: Table.message,
      where: where,
      whereArgs: [
        channelId,
        if (threadId != null) threadId,
        if (withExistedFiles == true) '[]'
      ],
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
    bool? withExistedFiles = false,
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
    if (withExistedFiles == true) {
      queryParameters['filter'] = 'files';
    }
    if (threadId == null) {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadsChannel, [
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
        .where((rm) =>
            rm['type'] == 'message' &&
            rm['subtype'] != 'system' &&
            rm['subtype'] !=
                'application') // TODO remove the last condition once the support for applications has been implemented
        .map((entry) => Message.fromJson(
              entry,
              channelId: channelId,
              jsonify: true,
              transform: true,
            ));

    await _storage.multiInsert(table: Table.message, data: remoteMessages);

    return await fetchLocal(
      channelId: channelId,
      threadId: threadId,
      withExistedFiles: withExistedFiles,
    );
  }

  Future<List<Message>> fetchAroundMessage({
    required String channelId,
    String? threadId,
    required String messageId,
    required String direction,
    required bool isDirect,
    int? limit,
  }) async {
    List<dynamic> remoteResult = [];
    final queryParameters = {
      'include_users': 1,
      'page_token': messageId,
      'direction': direction,
      'limit': limit ?? 20,
    };
    if (threadId == null) {
      try {
        remoteResult = await _api.get(
          endpoint: sprintf(
              isDirect ? Endpoint.threadsDirect : Endpoint.threadsChannel, [
            Globals.instance.companyId,
            isDirect ? 'direct' : Globals.instance.workspaceId,
            channelId
          ]),
          queryParameters: queryParameters,
          key: 'resources',
        );
      } catch (e) {
        Logger().e('Error occured during fetchAroundMessage:\n$e');
        return [];
      }
    } else {
      try {
        remoteResult = await _api.get(
          endpoint: sprintf(
            Endpoint.threadMessages,
            [
              Globals.instance.companyId,
              isDirect ? 'direct' : Globals.instance.workspaceId,
              threadId
            ],
          ),
          queryParameters: queryParameters,
          key: 'resources',
        );
      } catch (e) {
        Logger().e('Error occured during fetchAroundMessage:\n$e');
        return [];
      }
    }

    var remoteMessages = remoteResult
        .where((rm) =>
            rm['type'] == 'message' &&
            rm['subtype'] != 'system' &&
            rm['subtype'] !=
                'application') // TODO remove the last condition once the support for applications has been implemented
        .map((entry) => Message.fromJson(
              entry,
              jsonify: true,
              transform: true,
              channelId: channelId,
            ));

    await _storage.multiInsert(table: Table.message, data: remoteMessages);

    return remoteMessages.toList();
  }

  Future<List<Message>> fetchBefore({
    required String channelId,
    String? threadId,
    required String beforeMessageId,
    required bool isDirect,
  }) {
    return fetchAroundMessage(
        channelId: channelId,
        messageId: beforeMessageId,
        direction: 'history',
        isDirect: isDirect);
  }

  Future<List<Message>> fetchAfter({
    required String channelId,
    String? threadId,
    required String afterMessageId,
    required bool isDirect,
  }) {
    return fetchAroundMessage(
        channelId: channelId,
        messageId: afterMessageId,
        direction: 'future',
        isDirect: isDirect);
  }

  Stream<Message> send({
    required String id,
    required String channelId,
    required List<dynamic> prepared,
    List<dynamic> files: const [],
    String? originalStr,
    required String threadId,
    bool isDirect: false,
    required int now,
    String? companyId,
    String? workspaceId,
  }) async* {
    final result = await _storage.first(
      table: Table.account,
      where: 'id = ?',
      whereArgs: [Globals.instance.userId],
    );

    Account currentUser = Account.fromJson(json: result);

    final turn = _counter;
    _counter += 1;

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

    final finalCompanyId = companyId ?? Globals.instance.companyId;
    final finalWorkspaceId = workspaceId ?? Globals.instance.workspaceId;

    final data = threadId == id
        ? {
            'resource': {
              'participants': [
                {
                  'type': 'channel',
                  'id': channelId,
                  'workspace_id': isDirect ? 'direct' : finalWorkspaceId,
                  'company_id': finalCompanyId,
                }
              ]
            },
            'options': {
              'message': ApiDataTransformer.apiMessage(message: message)
            }
          }
        : {'resource': ApiDataTransformer.apiMessage(message: message)};

    final endpoint = threadId == id
        ? sprintf(Endpoint.threadsPost, [finalCompanyId])
        : sprintf(Endpoint.threadMessages, [finalCompanyId, threadId]);

    while (true) {
      await _sendGuard.acquire();
      if (_turn == turn) {
        _turn += 1;
        break;
      }
      _sendGuard.release();
    }
    try {
      final remoteResult = await _api.post(
        endpoint: endpoint,
        data: data,
        key: 'resource',
      );

      message = Message.fromJson(
        id == threadId ? remoteResult['message'] : remoteResult,
        jsonify: true,
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

    await Future.delayed(Duration(milliseconds: 200));

    _sendGuard.release();
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
        jsonify: true,
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
      jsonify: true,
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

  Future<bool> pinMesssage({
    required Message message,
  }) async {
    if (!Globals.instance.isNetworkConnected) return false;
    try {
      await _api.post(
          endpoint: sprintf(Endpoint.threadMessages,
                  [Globals.instance.companyId, message.threadId]) +
              '/${message.id}/pin',
          data: {'pin': 'true'});
    } catch (e) {
      Logger().e('Error occured during pin a massage:\n$e');
      return false;
    } finally {
      _storage.insert(table: Table.message, data: message);
    }
    return true;
  }

  Future<bool> unpinMesssage({
    required Message message,
  }) async {
    if (!Globals.instance.isNetworkConnected) return false;
    try {
      await _api.post(
          endpoint: sprintf(Endpoint.threadMessages,
                  [Globals.instance.companyId, message.threadId]) +
              '/${message.id}/pin',
          data: [],
          queryParameters: {'pin': 'false'});
    } catch (e) {
      Logger().e('Error occured during unpin a massage:\n$e');
      return false;
    } finally {
      message.pinnedInfo = null;

      _storage.insert(table: Table.message, data: message);
    }

    return true;
  }

  Future<List<Message>> fetchPinnedMesssages(
      {String? channelId, bool? isDirect}) async {
    final queryParameters = {'include_users': 1, 'filter': 'pinned', 'flat': 1};
    List<dynamic> remoteResult = [];
    Iterable<Message> remoteMessages = [];
    try {
      remoteResult = await _api.get(
        endpoint: sprintf(Endpoint.threadsChannel, [
          Globals.instance.companyId,
          isDirect == null
              ? Globals.instance.workspaceId
              : isDirect
                  ? 'direct'
                  : Globals.instance.workspaceId,
          channelId ?? Globals.instance.channelId,
        ]),
        queryParameters: queryParameters,
        key: 'resources',
      );
    } catch (e) {
      Logger().e('Error occured during fetch pin massages:\n$e');
      return [];
    } finally {
      remoteMessages = remoteResult
          .map((e) => e['message'])
          .where((rm) =>
              rm['type'] == 'message' &&
              rm['subtype'] != 'system' &&
              rm['subtype'] != 'application')
          .map((entry) => Message.fromJson(
                entry,
                channelId: Globals.instance.channelId,
                jsonify: true,
                transform: true,
              ));
    }

    return remoteMessages.toList();
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
          'reactions': reaction.isEmpty ? [] : [reaction]
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

    final message = Message.fromJson(result, jsonify: true, transform: true);

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
      jsonify: true,
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
