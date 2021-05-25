import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs_new/messages_cubit/messages_state.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/utils/twacode.dart';

export 'messages_state.dart';

abstract class BaseMessagesCubit extends Cubit<MessagesState> {
  late final MessagesRepository _repository;

  BaseMessagesCubit({MessagesRepository? repository})
      : super(MessagesInitial()) {
    if (repository == null) {
      repository = MessagesRepository();
    }
    _repository = repository;
  }

  Future<void> fetch({required String channelId, String? threadId}) async {
    emit(MessagesLoadInProgress());
    final stream = _repository.fetch(channelId: channelId, threadId: threadId);

    await for (var list in stream) {
      emit(MessagesLoadSuccess(
        messages: list,
        hash: list.fold(0, (acc, m) => acc + m.hash),
      ));
    }
  }

  Future<void> fetchBefore({
    String? threadId,
  }) async {
    if (this.state is! MessagesLoadSuccess) return;

    final state = this.state as MessagesLoadSuccess;
    emit(MessagesBeforeLoadInProgress(
      messages: state.messages,
      hash: state.hash,
    ));

    final beforeMessages = await _repository.fetchBefore(
      threadId: threadId,
      beforeMessageId: state.messages.first.id,
      beforeDate: state.messages.first.creationDate,
    );

    final allMessages = beforeMessages + state.messages;

    final newState = MessagesLoadSuccess(
      messages: allMessages,
      hash: allMessages.fold(0, (acc, m) => acc + m.hash),
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
    final sendStream = _repository.send(
        channelId: Globals.instance.channelId!,
        prepared: prepared,
        originalStr: originalStr,
        threadId: threadId);
    if (this.state is! MessagesLoadSuccess) return;

    final messages = (this.state as MessagesLoadSuccess).messages;
    final hash = (this.state as MessagesLoadSuccess).hash;

    await for (final message in sendStream) {
      // user might have changed screen, so make sure we are still in
      // messages view screen, and the state is MessagesLoadSuccess
      if (this.state is! MessagesLoadSuccess) return;

      final modifiedList = messages.sublist(0); // clone the original list
      modifiedList.add(message);

      emit(MessagesLoadSuccess(
        messages: modifiedList,
        hash: hash + message.hash,
      ));
    }
  }

  Future<void> edit({
    required Message message,
    required String editedText,
    List<File> newAttachments: const [],
    String? threadId,
  }) async {
    final prepared = TwacodeParser(editedText).message;
    if (newAttachments.isNotEmpty) {
      final oldPrepared = message.content.prepared;
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

    message.content =
        MessageContent(originalStr: editedText, prepared: prepared);
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

  void selectThread(Message message) {
    Globals.instance.threadIdSet = message.id;
  }

  void clearSelectedThread() {
    Globals.instance.threadIdSet = null;
  }

  Future<Message> get selectedThread async {
    final message =
        await _repository.getMessageLocal(Globals.instance.threadId!);

    return message;
  }
}

class ChannelMessagesCubit extends BaseMessagesCubit {
  // channel specific logic goes here
}

class ThreadMessagesCubit extends BaseMessagesCubit {
  // thread specific logic goes here
}
