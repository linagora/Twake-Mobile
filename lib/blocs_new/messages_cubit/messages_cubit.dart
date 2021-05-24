import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs_new/messages_cubit/messages_state.dart';
import 'package:twake/repositories/messages_repository.dart';

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
}
