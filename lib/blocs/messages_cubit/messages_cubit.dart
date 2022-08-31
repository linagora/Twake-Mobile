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
  late final BaseUnreadMessagesCubit _unreadMessagesCubit;

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

    if (unreadMessagesCubit == null) {
      unreadMessagesCubit = ChannelUnreadMessagesCubit();
    }
    _unreadMessagesCubit = unreadMessagesCubit;

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
      _unreadMessagesCubit.fetchUnreadMessages(
          messages: list, isDirect: isDirect);

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
    if (this.state is! MessagesLoadSuccess) return;
    if ((this.state as MessagesLoadSuccess).endOfHistory) return;

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
    final endOfHistory = messages.length <= 1;

    // if (endOfHistory) {
    //   // insert the dummy message for the endOfHistory widget
    //   messages.insert(0, dummy(oldestMessage.createdAt - 1));
    // }
    state.messages.addAll(messages);

    final newState = MessagesLoadSuccess(
      messages: state.messages,
      hash: messages.fold(0, (acc, m) => acc + m.hash),
      endOfHistory: endOfHistory,
    );

    emit(newState);
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
        final newState = MessagesLoadSuccess(
          messages: state.messages,
          hash: messages.fold(0, (acc, m) => acc + m.hash),
          endOfHistory: false,
        );

        emit(newState);
      });
    }
  }

  void fetchMessagesAroundPinned(
      {required List<Message> messages, required Message pinnedMessage}) {
    if (messages.isNotEmpty) {
      emit(MessagesAroundPinnedLoadSuccess(
          messages: messages,
          pinnedMessage: pinnedMessage,
          hash: messages.fold(0, (acc, m) => acc + m.hash),
          endOfHistory: false));
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
      final endOfHistory = (this.state as MessagesLoadSuccess).endOfHistory;

      final index = messages.indexWhere((m) => m.id == id);

      if (index.isNegative) {
        messages.add(message);
      } else {
        messages[index] = message;
      }

      emit(MessagesLoadSuccess(
        messages: messages,
        hash: hash + message.hash,
        endOfHistory: endOfHistory,
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
        files: attachments,quoteMessage: quoteMessage);

    final state = this.state as MessagesLoadSuccess;
    emit(MessageSendInProgress(messages: state.messages, hash: state.hash));

    await for (message in sendStream) {
      // user might have changed screen, so make sure we are still in
      // messages view screen, and the state is MessagesLoadSuccess
      if (this.state is! MessagesLoadSuccess) return;

      if (message.channelId != Globals.instance.channelId) return;

      final messages = (this.state as MessagesLoadSuccess).messages;
      final hash = (this.state as MessagesLoadSuccess).hash;
      final endOfHistory = (this.state as MessagesLoadSuccess).endOfHistory;

      final index = messages.indexWhere((m) => m.id == fakeId);

      if (index.isNegative) {
        messages.add(message);
      } else {
        messages[index] = message;
      }

      _unreadMessagesCubit.listenOwnerMessage();

      emit(MessageLatestSuccess(
        messages: messages,
        hash: hash + message.hash,
        latestMessage: messages.last,
      ));

      //after message is send successfully mark channel as read
      _baseChannelsCubit.markChannelRead(channelId: message.channelId);
    }

    _sendInProgress -= 1;
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
    final endOfHistory = (this.state as MessagesLoadSuccess).endOfHistory;

    message.blocks = prepared;
    message.text = editedText;
    // It's assumed that the message argument is also contained in
    // the messages list of the current state
    emit(MessagesLoadSuccess(
      messages: messages,
      // hash should be different from current state because we changed the text of message
      hash: messages.fold(0, (acc, m) => acc + m.hash),
      endOfHistory: endOfHistory,
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
    final endOfHistory = (this.state as MessagesLoadSuccess).endOfHistory;

    emit(MessagesLoadSuccess(
      messages: messages,
      // hash should be different from current state, as reactions were modified
      hash: messages.fold(0, (acc, m) => acc + m.hash),
      endOfHistory: endOfHistory,
    ));

    // As usual, we can try except here to roll back reactions if
    // API request fails
    _repository.react(message: message, reaction: unreacted ? '' : reaction);
  }

  Future<void> delete({required Message message}) async {
    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;
    final hash = (this.state as MessagesLoadSuccess).hash;
    final endOfHistory = (this.state as MessagesLoadSuccess).endOfHistory;
    message.subtype = MessageSubtype.deleted;

    emit(MessagesLoadSuccess(
      messages: messages,
      hash: hash - message.hash,
      endOfHistory: endOfHistory,
    ));

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

  Message dummy(int date) {
    return Message(
      id: '',
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
            messages.removeWhere((m) => m.id == change.resource['id']);
            emit(MessagesLoadSuccess(
              messages: messages,
              hash: hash - 1, // we only need to update hash in someway
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

              emit(MessagesLoadSuccess(
                messages: messages,
                hash: hash + 1, // we only need to update hash in someway
              ));
            } else {
              // update unread messages
              _unreadMessagesCubit.listenNotOwnerMessage();
              // new message has been created
              messages.add(message);
              messages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
              final newState = MessageLatestSuccess(
                messages: messages,
                hash: hash + message.hash,
                latestMessage: message,
              );
              emit(newState);
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
        if (connect) {
          List<Message>? messages;
          do {
            if (currentState.messages.isNotEmpty) {
              Message latestMessage = currentState.messages.reduce(
                  (value, element) =>
                      value.createdAt > element.createdAt ? value : element);
              messages = await _repository.fetchAfter(
                  channelId: latestMessage.channelId,
                  afterMessageId: latestMessage.id,
                  workspaceId:
                      isDirect! ? 'direct' : Globals.instance.workspaceId);

              if (messages.isEmpty) {
                continue;
              }
              Message newLatestMessage = messages.reduce((value, element) =>
                  value.createdAt > element.createdAt ? value : element);
              if (newLatestMessage == latestMessage) {
                continue;
              }

              // remove lastest messages in current state because it's also in api
              currentState.messages.remove(latestMessage);
              currentState.messages.addAll(messages);
              emit(MessagesLoadSuccess(
                  messages: currentState.messages,
                  hash:
                      currentState.messages.fold(0, (acc, m) => acc + m.hash)));
            }
          } while (messages != null);
        }
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
              messages: messages,
              hash: hash - oldHash + message.hash,
            ));
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

            final i = messages
                .indexWhere((m) => m.id == change.resource['thread_id']);

            messages[i] = message;

            // mark message as read
            _baseChannelsCubit.markChannelRead(channelId: message.channelId);
            final newState = MessageLatestSuccess(
              messages: messages,
              hash:
                  hash + message.hash, // just update the hash to force rerender
              latestMessage: message,
            );

            emit(newState);
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
