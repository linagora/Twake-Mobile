import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/reaction.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/twacode.dart';

export 'messages_state.dart';

abstract class BaseMessagesCubit extends Cubit<MessagesState> {
  late final MessagesRepository _repository;

  late BaseChannelsCubit _baseChannelsCubit;
  late final BaseChannelsCubit _channelsCubit;
  late final BaseChannelsCubit _directsCubit;

  final _socketIOResourceStream = SocketIOService.instance.resourceStream;
  final _socketIOReconnectionStream =
      SocketIOService.instance.socketIOReconnectionStream;

  int _sendInProgress = 0;
  bool? isDirect;

  BaseMessagesCubit(
      {MessagesRepository? repository,
      BaseChannelsCubit? channelCubit,
      BaseChannelsCubit? directsCubit,
      BaseUnreadMessagesCubit? unreadMessagesCubit})
      : super(MessagesInitial()) {
    if (repository == null) {
      repository = MessagesRepository();
    }
    _repository = repository;

    if (channelCubit == null) {
      channelCubit = ChannelsCubit();
    }
    _channelsCubit = channelCubit;

    if (directsCubit == null) {
      directsCubit = DirectsCubit();
    }
    _directsCubit = directsCubit;

    listenToMessageChanges();
    listenToReconnectionChange();
  }

  Future<void> fetch({
    required String channelId,
    String? threadId,
    isDirect: false,
    bool empty: false,
  }) async {
    this.isDirect = isDirect;
    if (isDirect) {
      _baseChannelsCubit = _directsCubit;
    } else {
      _baseChannelsCubit = _channelsCubit;
    }

    if (empty) {
      emit(NoMessagesFound());
      return;
    }

    if (threadId == null) emit(MessagesLoadInProgress());

    final stream = _repository.fetch(
      channelId: channelId,
      threadId: threadId,
      workspaceId: isDirect ? 'direct' : null,
    );

    threadId = threadId ?? Globals.instance.threadId;

    List<Message> lastList = const [];
    await for (var list in stream) {
      // if user switched channel before the fetch method is complete, abort
      if (channelId != Globals.instance.channelId) return;

      // if user switched thread before the fetch method is complete, abort
      if (threadId != null && threadId != Globals.instance.threadId) return;

      lastList = list;

      emit(MessagesLoadSuccess(
        messages: list,
        hash: list.fold(0, (acc, m) => acc + m.hash),
      ));

      if (lastList.isEmpty && threadId == null) {
        emit(NoMessagesFound());
      }
    }

    _baseChannelsCubit.markChannelRead(channelId: channelId);
  }

  Future<void> fetchBefore({
    required String channelId,
    String? threadId,
    required bool isDirect,
  }) async {
    // wait for previous fetch finish before continue
    if (this.state is! MessagesLoadSuccess) return;
    final state = this.state as MessagesLoadSuccess;

    emit(MessagesBeforeLoadInProgress(
      messages: state.messages,
      hash: state.hash,
    ));

    final oldestMessage = state.messages.last;

    //last message will be first message
    var messages = await _repository.fetchBefore(
      channelId: channelId,
      threadId: threadId,
      beforeMessageId: oldestMessage.id,
      workspaceId: isDirect ? 'direct' : null,
    );
    messages.remove(oldestMessage);

    // if user switched channel before the fetchBefore method is complete, abort
    // and just ignore the result
    if (channelId != Globals.instance.channelId) return;

    final endOfHistory = messages.length < 1;

    if (endOfHistory) {
      // insert the dummy message to the list if not already inserted
      final myListFiltered =
          state.messages.where((m) => m.id == 'endOfHistory');
      if (myListFiltered.length == 0)
        messages.insert(
            0, dummy(date: oldestMessage.createdAt - 1, id: 'endOfHistory'));
    }

    state.messages
        .addAll(messages.where((message) => !state.messages.contains(message)));

    final List<Message> newMessages = [];
    state.messages.forEach((m) {
      final int res = newMessages.indexWhere((nM) => nM.id == m.id);

      if (res == -1) newMessages.add(m);
    });

    emit(MessagesLoadSuccess(
      messages: newMessages,
      hash: messages.fold(0, (acc, m) => acc + m.hash),
    ));
  }

  Future<void> fetchAfter({
    required String channelId,
    String? threadId,
    required bool isDirect,
  }) async {
    if (this.state is! MessagesLoadSuccess) return;
    final state = this.state as MessagesLoadSuccess;
    final lock = Globals.instance.lock;

    // wait for previous fetch finish before continue
    if (!lock.locked) {
      await lock.synchronized(() async {
        emit(MessagesBeforeLoadInProgress(
          messages: state.messages,
          hash: state.hash,
        ));

        final lastestMessage = state.messages.first;
        //first message will be lastest message
        final messages = await _repository.fetchAfter(
          channelId: channelId,
          threadId: threadId,
          afterMessageId: lastestMessage.id,
          workspaceId: isDirect ? 'direct' : null,
        );

        if (messages.isEmpty) {
          return;
        }
        if (channelId != Globals.instance.channelId) return;

        state.messages.addAll(messages
            .where((element) => element.createdAt > lastestMessage.createdAt));

        final List<Message> newMessages = [];
        state.messages.forEach((m) {
          final int res = newMessages.indexWhere((nM) => nM.id == m.id);

          if (res == -1) newMessages.add(m);
        });

        emit(MessagesLoadSuccess(
          messages: newMessages,
          hash: messages.fold(0, (acc, m) => acc + m.hash),
        ));
      });
    }
  }

  Future<List<Message>> getMessagesAroundSelectedMessage(
      {required Message message,
      String? threadId,
      required bool isDirect}) async {
    final messages = await _repository.fetchBefore(
        channelId: message.channelId,
        beforeMessageId: message.id,
        threadId: threadId,
        workspaceId: isDirect ? 'direct' : null);
    if (messages.isNotEmpty) {
      messages.removeLast();
    }
    messages.addAll(await _repository.fetchAfter(
        channelId: message.channelId,
        afterMessageId: message.id,
        workspaceId: isDirect ? 'direct' : null));

    if (messages.isEmpty) {
      return [];
    } else {
      emit(MessagesLoadSuccess(
        messages: messages,
        hash: messages.fold(0, (acc, m) => acc + m.hash),
      ));

      return messages;
    }
  }

  Future<void> resend({required Message message, bool isDirect: false}) async {
    _sendInProgress += 1;

    final sendStream = _repository.resend(
      message: message,
      isDirect: isDirect,
    );

    final id = message.id;

    await for (final message in sendStream) {
      // user might have changed screen, so make sure we are still in
      // messages view screen, and the state is MessagesLoadSuccess
      if (this.state is! MessagesLoadSuccess) return;

      if (message.channelId != Globals.instance.channelId) return;

      final messages = (this.state as MessagesLoadSuccess).messages;
      final hash = (this.state as MessagesLoadSuccess).hash;

      final index = messages.indexWhere((m) => m.id == id);

      if (index.isNegative) {
        messages.add(message);
      } else {
        messages[index] = message;
      }

      emit(MessagesLoadSuccess(
        messages: messages,
        hash: hash + message.hash,
      ));

      _baseChannelsCubit.markChannelRead(channelId: message.channelId);
    }

    _sendInProgress -= 1;
  }

  Future<void> sendInSharing({
    String? originalStr,
    List<dynamic> attachments: const [],
    String? threadId,
    bool isDirect: false,
    String? companyId,
    String? workspaceId,
    String? channelId,
  }) async {
    final prepared = TwacodeParser(originalStr ?? '').message;
    final fakeId = DateTime.now().millisecondsSinceEpoch.toString();
    final sendStream = _repository.send(
      id: fakeId,
      channelId: channelId ?? Globals.instance.channelId!,
      prepared: prepared,
      originalStr: originalStr,
      threadId: threadId ?? fakeId,
      isDirect: isDirect,
      now: DateTime.now().millisecondsSinceEpoch,
      files: attachments,
      companyId: companyId,
      workspaceId: workspaceId,
    );
    await for (final message in sendStream) {}
  }

  Future<void> send(
      {String? originalStr,
      List<dynamic> attachments: const [],
      String? threadId,
      bool isDirect: false,
      Message? quoteMessage}) async {
    final prepared = TwacodeParser(originalStr ?? '').message;
    final fakeId = DateTime.now().millisecondsSinceEpoch.toString();
    Message message;

    _sendInProgress += 1;

    final sendStream = _repository.send(
        id: fakeId,
        channelId: Globals.instance.channelId!,
        prepared: prepared,
        originalStr: originalStr,
        threadId: threadId ?? fakeId,
        isDirect: isDirect,
        now: DateTime.now().millisecondsSinceEpoch,
        files: attachments,
        quoteMessage: quoteMessage);

    final state = this.state as MessagesLoadSuccess;
    emit(MessageSendInProgress(messages: state.messages, hash: state.hash));

    await for (message in sendStream) {
      // user might have changed screen, so make sure we are still in
      // messages view screen, and the state is MessagesLoadSuccess
      if (this.state is! MessagesLoadSuccess) return;

      if (message.channelId != Globals.instance.channelId) return;

      final messages = (this.state as MessagesLoadSuccess).messages;
      final hash = (this.state as MessagesLoadSuccess).hash;

      final index = messages.indexWhere((m) => m.id == fakeId);

      if (index.isNegative) {
        messages.add(message);
      } else {
        messages[index] = message;
      }

      final List<Message> newMessages = [];
      messages.forEach((m) {
        final int res = newMessages.indexWhere((nM) => nM.id == m.id);

        if (res == -1) newMessages.add(m);
      });

      emit(MessagesLoadSuccess(
        messages: newMessages,
        hash: hash + message.hash,
      ));

      //after message is send successfully mark channel as read
      _baseChannelsCubit.markChannelRead(channelId: message.channelId);
    }

    _sendInProgress -= 1;
  }

  Future<void> sendLocal() async {
    final message = _repository.sendLocal();

    final messages = (this.state as MessagesLoadSuccess).messages;
    final hash = (this.state as MessagesLoadSuccess).hash;
    messages.add(message);

    emit(MessagesLoadSuccess(
      messages: messages,
      hash: hash + message.hash,
    ));
  }

  Future<void> removeFromState(String id) async {
    final messages = (this.state as MessagesLoadSuccess).messages;
    final hash = (this.state as MessagesLoadSuccess).hash;

    messages.removeWhere((m) => m.id == id);

    emit(MessagesLoadSuccess(
      messages: messages,
      hash: hash,
    ));
  }

  void startEdit({required Message message}) async {
    if (state is! MessagesLoadSuccess) return;

    final s = (state as MessagesLoadSuccess);

    // reinstate files from message for editing
    // TODO: uncomment when enable edit file feature
    // await Get.find<FileUploadCubit>().startEditingFile(message);

    emit(MessageEditInProgress(
      messages: s.messages,
      hash: s.hash,
      message: message,
    ));
  }

  Future<void> edit({
    required Message message,
    required String editedText,
    List<dynamic> newAttachments: const [],
    String? threadId,
  }) async {
    final prepared = TwacodeParser(editedText).message;

    if (newAttachments.isNotEmpty) {
      message.files = newAttachments;
    } else {
      message.files = null;
    }

    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;

    message.blocks = prepared;
    message.text = editedText;
    // It's assumed that the message argument is also contained in
    // the messages list of the current state
    emit(MessagesLoadSuccess(
      messages: messages,
      // hash should be different from current state because we changed the text of message
      hash: messages.fold(0, (acc, m) => acc + m.hash),
    ));
    // here we can use try except to revert the message to original state
    // if the request to API failed for some reason
    _repository.edit(message: message);
  }

  Future<void> react({
    required Message message,
    required String reaction,
  }) async {
    final rx = message.reactions;
    final present = rx.any((r) => r.name == reaction);
    final reacted = rx.firstWhere(
      (r) => r.name == reaction,
      orElse: () => Reaction(
        name: reaction,
        users: [],
        count: 1,
      ),
    );
    final userId = Globals.instance.userId!;
    bool unreacted = false;
    if (present) {
      if (reacted.users.contains(userId)) {
        reacted.users.remove(userId);
        unreacted = true;
      } else {
        reacted.users.add(userId);
      }
      reacted.count = reacted.users.length;
    } else {
      reacted.users.add(Globals.instance.userId!);
      rx.add(reacted);
    }

    rx.where((r) => r.name != reaction).forEach((r) => r.users.remove(userId));

    rx.removeWhere((r) => r.users.isEmpty);

    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;

    emit(MessagesLoadSuccess(
      messages: messages,
      // hash should be different from current state, as reactions were modified
      hash: messages.fold(0, (acc, m) => acc + m.hash),
    ));

    // As usual, we can try except here to roll back reactions if
    // API request fails
    _repository.react(message: message, reaction: unreacted ? '' : reaction);
  }

  Future<void> delete({required Message message, bool local: false}) async {
    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;
    final hash = (this.state as MessagesLoadSuccess).hash;
    message.subtype = MessageSubtype.deleted;

    emit(MessagesLoadSuccess(
      messages: messages,
      hash: hash - message.hash,
    ));

    if (local) {
      _repository.removeMessageLocal(messageId: message.id);
      return;
    }
    // Again, here we can use try except to undelete the message
    // if the request to API failed for some reason
    _repository.delete(messageId: message.id, threadId: message.threadId);
    _repository.saveOne(message: message);
  }

  void selectThread({required String messageId}) {
    Globals.instance.threadIdSet = messageId;

    SynchronizationService.instance
        .subscribeToThreadReplies(threadId: messageId);
  }

  void clearSelectedThread() {
    if (Globals.instance.threadId != null)
      SynchronizationService.instance
          .unsubscribeFromThreadReplies(threadId: Globals.instance.threadId!);

    Globals.instance.threadIdSet = null;
  }

  Future<Message> get selectedThread async {
    final message = await _repository.getMessage(
      messageId: Globals.instance.threadId!,
    );

    return message;
  }

  void saveDraft({String? draft}) {
    if (state is! MessagesLoadSuccess) return;

    final thread = (state as MessagesLoadSuccess).messages.first;

    thread.draft = draft;

    _repository.saveOne(message: thread);
  }

  Message dummy({required int date, required String id}) {
    return Message(
      id: id,
      threadId: '',
      channelId: '',
      blocks: const [],
      createdAt: date,
      updatedAt: date,
      responsesCount: 0,
      username: '',
      userId: '',
      text: '',
      reactions: const [],
      files: const [],
    );
  }

  Future<void> listenToMessageChanges() async {
    await for (final change in _socketIOResourceStream) {
      switch (change.action) {
        case ResourceAction.deleted:
          _repository.removeMessageLocal(messageId: change.resource['id']);
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;
            //  final endOfHistory = (state as MessagesLoadSuccess).endOfHistory;
            messages.removeWhere((m) => m.id == change.resource['id']);
            emit(MessagesLoadSuccess(
              messages: messages,
              hash: hash - 1,
              //    endOfHistory:
              //        endOfHistory, // we only need to update hash in someway
            ));
          }
          break;
        case ResourceAction.created:
        case ResourceAction.saved:
        case ResourceAction.updated:
          final message = await _repository.getMessageRemote(
            messageId: change.resource['id'],
            threadId: change.resource['thread_id'],
          );
          //  final message = Message.fromJson(change.resource,
          //    transform: true, jsonify: false);
          if (message.userId == Globals.instance.userId && _sendInProgress > 0)
            continue;

          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;

            // update channel read
            _baseChannelsCubit.markChannelRead(channelId: message.channelId);

            // message is already present
            if (messages.any((m) => m.id == message.id)) {
              final index = messages.indexWhere((m) => m.id == message.id);

              messages[index] = message;

              emit(MessagesLoadSuccess(messages: messages, hash: hash + 1));
            } else {
              // new message has been created
              messages.add(message);
              messages.sort((m1, m2) => m2.createdAt.compareTo(m1.createdAt));
              emit(MessagesLoadSuccess(messages: messages, hash: hash + 1));
            }
          }
          break;
        case ResourceAction.event:
          break;
      }
    }
  }

  Future<void> listenToReconnectionChange() async {
    // track last message when network down
    await for (final connect in _socketIOReconnectionStream) {
      // if user have not entered any chat, ignore connect
      if (isDirect == null) {
        continue;
      }
      if (state is MessagesLoadSuccess) {
        final currentState = state as MessagesLoadSuccess;
        if (connect)
          fetch(
              channelId: currentState.messages.first.channelId,
              isDirect: isDirect);
      }
    }
  }

  void reset() {
    emit(MessagesInitial());
  }
}

class ChannelMessagesCubit extends BaseMessagesCubit {
  @override
  final _socketIOResourceStream =
      SynchronizationService.instance.socketIOChannelMessageStream;

  ChannelMessagesCubit(
      {MessagesRepository? repository,
      BaseChannelsCubit? channelsCubit,
      BaseChannelsCubit? directsCubit,
      ChannelUnreadMessagesCubit? unreadMessagesCubit})
      : super(
            repository: repository,
            channelCubit: channelsCubit,
            directsCubit: directsCubit,
            unreadMessagesCubit: unreadMessagesCubit) {
    listenToThreadChanges();
  }

  Future<void> listenToThreadChanges() async {
    final threadsStream =
        SynchronizationService.instance.socketIOThreadMessageStream;

    await for (final change in threadsStream) {
      switch (change.action) {
        case ResourceAction.deleted:
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;

            if (!messages.any((m) => m.id == change.resource['thread_id']))
              continue;

            final message = messages
                .firstWhere((m) => m.id == change.resource['thread_id']);

            final oldHash = message.hash;
            message.responsesCount -= 1;

            emit(MessagesLoadSuccess(
                messages: messages, hash: hash - oldHash + message.hash));
          }
          break;

        case ResourceAction.created:
        case ResourceAction.saved:
        case ResourceAction.updated:
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;

            final message = await _repository.getMessageRemote(
              messageId: change.resource['thread_id'],
              threadId: change.resource['thread_id'],
            );
            //final message = Message.fromJson(change.resource);

            // mark message as read
            _baseChannelsCubit.markChannelRead(channelId: message.channelId);
            // message is already present
            if (messages.any((m) => m.id == message.id)) {
              final index = messages.indexWhere((m) => m.id == message.id);

              messages[index] = message;
              emit(MessagesLoadSuccess(messages: messages, hash: hash + 1));
            }
          }
          break;
        case ResourceAction.event:
          break;
      }
    }
  }
}

class ThreadMessagesCubit extends BaseMessagesCubit {
  ThreadMessagesCubit(
      {MessagesRepository? repository,
      ThreadUnreadMessagesCubit? unreadMessageCubit})
      : super(repository: repository, unreadMessagesCubit: unreadMessageCubit);

  @override
  final _socketIOResourceStream = SynchronizationService
      .instance.socketIOThreadMessageStream
      .where((e) => e.resource['thread_id'] == Globals.instance.threadId);
}
