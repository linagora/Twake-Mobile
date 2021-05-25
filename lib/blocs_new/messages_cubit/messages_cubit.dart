import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs_new/messages_cubit/messages_state.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/utils/twacode.dart';

export 'messages_state.dart';

class BaseMessagesCubit extends Cubit<MessagesState> {
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

    await for (final message in sendStream) {
      // user might have changed screen, so make sure we are still in
      // messages view screen, and the state is MessagesLoadSuccess
      if (this.state is! MessagesLoadSuccess) return;

      final modifiedList = messages.sublist(0); // clone the original list
      modifiedList.add(message);

      emit(MessagesLoadSuccess(
        messages: modifiedList,
        hash: modifiedList.fold(0, (acc, m) => acc + m.hash),
      ));
    }
  }

  Future<void> edit({
    required Message message,
    required String editedText,
    List<File> newAttachments: const [],
  }) async {}
}
