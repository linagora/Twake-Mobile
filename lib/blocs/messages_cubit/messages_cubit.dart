import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/reaction.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/twacode.dart';

export 'messages_state.dart';

abstract class BaseMessagesCubit extends Cubit<MessagesState> {
  late final MessagesRepository _repository;

  final _socketIOEventStream = SocketIOService.instance.eventStream;

  bool _sendInProgress = false;

  BaseMessagesCubit({MessagesRepository? repository})
      : super(MessagesInitial()) {
    if (repository == null) {
      repository = MessagesRepository();
    }
    _repository = repository;

    listenToMessageChanges();
  }

  Future<void> fetch({
    required String channelId,
    String? threadId,
    isDirect: false,
  }) async {
    emit(MessagesLoadInProgress());

    final stream = _repository.fetch(
      channelId: channelId,
      threadId: threadId,
      workspaceId: isDirect ? 'direct' : null,
    );

    Message? parentMessage;

    threadId = threadId ?? Globals.instance.threadId;

    if (threadId != null) {
      parentMessage = await _repository.getMessage(messageId: threadId);
    }

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
        parentMessage: parentMessage,
      ));
    }

    if (lastList.isEmpty && threadId == null) {
      emit(NoMessagesFound());
    }
  }

  Future<void> swipeReply(
    String threadId,
  ) async {
    final parentMessage = await _repository.getMessage(messageId: threadId);

    emit(MessagesLoadSuccess(
      messages: [],
      hash: 0,
      parentMessage: parentMessage,
    ));
  }

  Future<void> fetchBefore({
    required String channelId,
    String? threadId,
  }) async {
    if (this.state is! MessagesLoadSuccess) return;

    final state = this.state as MessagesLoadSuccess;

    emit(MessagesBeforeLoadInProgress(
      messages: state.messages,
      hash: state.hash,
      parentMessage: state.parentMessage,
    ));

    final messages = await _repository.fetchBefore(
      channelId: channelId,
      threadId: threadId,
      beforeMessageId: state.messages.first.id,
    );
    // if user switched channel before the fetchBefore method is complete, abort
    // and just ignore the result
    if (channelId != Globals.instance.channelId) return;

    final newState = MessagesLoadSuccess(
      messages: messages,
      hash: messages.fold(0, (acc, m) => acc + m.hash),
      parentMessage: state.parentMessage,
    );

    emit(newState);
  }

  Future<void> send({
    String? originalStr,
    List<File> attachments: const [],
    String? threadId,
  }) async {
    final prepared = TwacodeParser(originalStr).message;
    if (attachments.isNotEmpty) {
      final nop = {
        'type': 'nop',
        'content': attachments.map((f) => f.toMap()).toList(),
      };
      prepared.add(nop);
    }
    final fakeId = DateTime.now().toString();

    final sendStream = _repository.send(
      id: fakeId,
      channelId: Globals.instance.channelId!,
      prepared: prepared,
      originalStr: originalStr,
      threadId: threadId ?? fakeId,
    );

    _sendInProgress = true;

    await for (final message in sendStream) {
      // user might have changed screen, so make sure we are still in
      // messages view screen, and the state is MessagesLoadSuccess
      if (this.state is! MessagesLoadSuccess) return;

      if (message.channelId != Globals.instance.channelId) return;

      final messages = this.state is MessagesLoadSuccess
          ? (this.state as MessagesLoadSuccess).messages
          : const <Message>[];
      final hash = this.state is MessagesLoadSuccess
          ? (this.state as MessagesLoadSuccess).hash
          : 0;

      final index = messages.indexWhere((m) => m.id == fakeId);

      if (index.isNegative) {
        messages.add(message);
      } else {
        messages[index] = message;
      }

      emit(MessagesLoadSuccess(
        messages: messages,
        hash: hash + message.hash,
      ));
    }

    _sendInProgress = false;
  }

  void startEdit({required Message message}) {
    if (state is! MessagesLoadSuccess) return;

    final s = (state as MessagesLoadSuccess);

    emit(MessageEditInProgress(
      messages: s.messages,
      hash: s.hash,
      parentMessage: s.parentMessage,
      message: message,
    ));
  }

  Future<void> edit({
    required Message message,
    required String editedText,
    List<File> newAttachments: const [],
    String? threadId,
  }) async {
    final prepared = TwacodeParser(editedText).message;

    if (newAttachments.isNotEmpty) {
      final oldPrepared = message.blocks;
      final content = newAttachments.map((f) => f.toMap()).toList();
      Map<String, dynamic> nop = {};
      if (oldPrepared.last['type'] == 'nop') {
        // if it already has attachments, then merge them
        nop = oldPrepared.last;
        nop['content'] = nop['content'] + content;
      } else {
        // else create new attachments
        nop['type'] = 'nop';
        nop['content'] = content;
      }
      prepared.add(nop);
    }

    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;

    message.blocks = prepared;
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
        users: [Globals.instance.userId!],
        count: 1,
      ),
    );
    final userId = Globals.instance.userId!;
    if (present) {
      if (reacted.users.contains(userId)) {
        reacted.users.remove(userId);
      } else {
        reacted.users.add(userId);
      }
      reacted.count = reacted.users.length;
    } else {
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
    _repository.react(message: message, reaction: reaction);
  }

  Future<void> delete({required Message message}) async {
    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;
    final hash = (this.state as MessagesLoadSuccess).hash;
    messages.removeWhere((m) => m.id == message.id);

    emit(MessagesLoadSuccess(messages: messages, hash: hash - message.hash));

    // Again, here we can use try except to undelete the message
    // if the request to API failed for some reason
    _repository.delete(messageId: message.id, threadId: message.threadId);
  }

  void selectThread({required String messageId}) {
    Globals.instance.threadIdSet = messageId;
  }

  void clearSelectedThread() {
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
    if ((state as MessagesLoadSuccess).parentMessage == null) return;

    final thread = (state as MessagesLoadSuccess).parentMessage!;

    thread.draft = draft;

    _repository.saveOne(message: thread);
  }

  Future<void> listenToMessageChanges() async {
    await for (final change in _socketIOEventStream) {
      switch (change.data.action) {
        case IOEventAction.remove:
          _repository.removeMessageLocal(messageId: change.data.messageId);
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;
            final parentMessage = (state as MessagesLoadSuccess).parentMessage;
            if (messages.first.channelId == change.channelId) {
              messages.removeWhere((m) => m.id == change.data.messageId);
              emit(MessagesLoadSuccess(
                messages: messages,
                hash: hash - 1, // we only need to update hash in someway
                parentMessage: parentMessage,
              ));
            }
          }
          break;
        case IOEventAction.update:
          final message = await _repository.getMessageRemote(
            messageId: change.data.messageId,
            threadId: change.data.threadId,
          );
          if (message.userId == Globals.instance.userId && _sendInProgress)
            continue;
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;
            final parentMessage = (state as MessagesLoadSuccess).parentMessage;
            if (Globals.instance.channelId == change.channelId) {
              // message is already present
              if (messages.any((m) => m.id == message.id)) {
                final index = messages.indexWhere((m) => m.id == message.id);

                messages[index] = message;

                emit(MessagesLoadSuccess(
                  messages: messages,
                  hash: hash + 1, // we only need to update hash in someway
                  parentMessage: parentMessage,
                ));
              } else {
                // new message has been created
                messages.add(message);
                final newState = MessagesLoadSuccess(
                  messages: messages,
                  hash: hash + message.hash,
                  parentMessage: parentMessage,
                );
                emit(newState);
              }
            }
          }
          break;
      }
    }
  }

  void reset() {
    emit(MessagesInitial());
  }
}

class ChannelMessagesCubit extends BaseMessagesCubit {
  @override
  final _socketIOEventStream =
      SynchronizationService.instance.socketIOChannelMessageStream;

  ChannelMessagesCubit({MessagesRepository? repository})
      : super(repository: repository) {
    listenToThreadChanges();
  }

  Future<void> listenToThreadChanges() async {
    final threadsStream =
        SynchronizationService.instance.socketIOThreadMessageStream;

    await for (final change in threadsStream) {
      Logger().v('GOT thread change');
      switch (change.data.action) {
        case IOEventAction.remove:
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;

            if (!messages.any((m) => m.id == change.data.threadId)) continue;

            final message =
                messages.firstWhere((m) => m.id == change.data.threadId);

            final oldHash = message.hash;
            message.responsesCount -= 1;

            emit(MessagesLoadSuccess(
              messages: messages,
              hash: hash - oldHash + message.hash,
            ));
          }
          break;
        case IOEventAction.update:
          if (state is MessagesLoadSuccess) {
            final messages = (state as MessagesLoadSuccess).messages;
            final hash = (state as MessagesLoadSuccess).hash;

            if (!messages.any((m) => m.id == change.data.threadId)) continue;

            final message = await _repository.getMessageRemote(
              messageId: change.data.messageId,
              threadId: change.data.threadId,
            );

            final i = messages.indexWhere((m) => m.id == change.data.threadId);

            messages[i] = message;

            final newState = MessagesLoadSuccess(
              messages: messages,
              hash: hash + message.hash,
            );
            print('Will emit: ${state != newState}');

            emit(newState);
          }
          break;
      }
    }
  }
}

class ThreadMessagesCubit extends BaseMessagesCubit {
  ThreadMessagesCubit({MessagesRepository? repository})
      : super(repository: repository);

  @override
  final _socketIOEventStream = SynchronizationService
      .instance.socketIOThreadMessageStream
      .where((e) => e.data.threadId == Globals.instance.threadId);
}
