import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/services/socketio_service.dart';
import 'package:twake/services/synchronization_service.dart';

part 'pinned_messsage_state.dart';

class PinnedMessageCubit extends Cubit<PinnedMessageState> {
  late final MessagesRepository _messageRepository;

  @override
  final _socketIOEventStream =
      SynchronizationService.instance.socketIOChannelMessageStream;

  PinnedMessageCubit({MessagesRepository? messagesRepository})
      : super(PinnedMessageState()) {
    if (messagesRepository == null) {
      messagesRepository = MessagesRepository();
    }
    _messageRepository = messagesRepository;
    listenToPinnedMessageChanges();
  }

  Future<void> init() async {
    emit(state.copyWith(
      newPinnedMesssageStatus: PinnedMessageStatus.init,
    ));
  }

  Future<bool> unpinAllMessages() async {
    if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.loading,
          newIsUnpinAll: true));
      final messages = state.pinnedMessageList;
      bool result;

      for (var i = 0; i < messages.length; i++) {
        result = await _messageRepository.unpinMesssage(message: messages[i]);
        if (result == false) {
          return false;
        }
      }
      emit(state.copyWith(newPinnedMesssageStatus: PinnedMessageStatus.init));
      return true;
    }
    return false;
  }

  Future<void> getPinnedMessages(String channelId, bool? isDirect) async {
    final messages = await _messageRepository.fetchPinnedMesssages(
        channelId: channelId, isDirect: isDirect);
    if (messages.isNotEmpty) {
      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.finished,
          newPinnedMessageList: messages,
          newSelected: state.selected,
          newIsUnpinAll: state.isUnpinAll));
    } else
      return;
  }

  Future<bool> selectPinnedMessage() async {
    if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
      final messages = state.pinnedMessageList;

      final selected =
          messages.length - 1 == state.selected ? 0 : state.selected + 1;

      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.selected,
          newPinnedMessageList: messages,
          newSelected: selected,
          newIsUnpinAll: state.isUnpinAll));

      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.finished,
          newPinnedMessageList: messages,
          newSelected: selected,
          newIsUnpinAll: state.isUnpinAll));
      return true;
    }
    return false;
  }

  Future<List<Message>> getMessagesAroundSelectedMessage(
      {required Message message,
      String? threadId,
      required bool isDirect}) async {
    final messages = await _messageRepository.fetchBefore(
        channelId: message.channelId,
        beforeMessageId: message.id,
        threadId: threadId,
        workspaceId: isDirect ? 'direct' : null);
    if (messages.isNotEmpty) {
      messages.removeLast();
    }
    messages.addAll(await _messageRepository.fetchAfter(
        channelId: message.channelId,
        afterMessageId: message.id,
        workspaceId: isDirect ? 'direct' : null));

    if (messages.isEmpty) {
      emit(MessagesAroundSelectedMessageFailed(
          pinnedMessageList: state.pinnedMessageList,
          pinnedMesssageStatus: PinnedMessageStatus.finished));
      return [];
    } else {
      emit(MessagesAroundSelectecMessageSuccess(
          pinnedMesssageStatus: PinnedMessageStatus.finished,
          pinnedMessageList: state.pinnedMessageList,
          selected: state.selected,
          messagesAround: messages,
          isUnpinAll: state.isUnpinAll));
      return messages;
    }
  }

  Future<bool> pinMessage({required Message message, bool? isDirect}) async {
    List<Message> messages = [];

    if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
      messages = state.pinnedMessageList;
    }

    messages.add(message);
    final bool isPin = await _messageRepository.pinMesssage(message: message);
    if (isPin) {
      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.finished,
          newPinnedMessageList: messages,
          newSelected: 0,
          newIsUnpinAll: state.isUnpinAll));

      final newMessages =
          await _messageRepository.fetchPinnedMesssages(isDirect: isDirect);

      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.finished,
          newPinnedMessageList:
              newMessages.isNotEmpty ? newMessages : state.pinnedMessageList,
          newSelected: 0,
          newIsUnpinAll: state.isUnpinAll));
      return true;
    } else
      return false;
  }

  Future<bool> unpinMessage({required Message message}) async {
    if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
      final messages = state.pinnedMessageList;

      final bool isUnpin =
          await _messageRepository.unpinMesssage(message: message);

      // if it's the last pinned message emit init
      if (messages.length == 1 && isUnpin) {
        emit(state.copyWith(newPinnedMesssageStatus: PinnedMessageStatus.init));
        return true;
      }
      if (isUnpin) {
        final int newSelected = (messages[state.selected].id == message.id)
            ? (messages.length - 1 == state.selected)
                ? 0
                : state.selected
            : state.selected;

        emit(state.copyWith(
            newPinnedMesssageStatus: PinnedMessageStatus.finished,
            newPinnedMessageList: messages,
            newSelected: newSelected,
            newIsUnpinAll: state.isUnpinAll));
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> unpinAllReset() async {
    emit(state.copyWith(newIsUnpinAll: false));
  }

  Future<void> listenToPinnedMessageChanges() async {
    await for (final change in _socketIOEventStream) {
      switch (change.action) {
        case ResourceAction.deleted:
        case ResourceAction.created:
        case ResourceAction.saved:
        case ResourceAction.updated:
          int selected;
          final messages = await _messageRepository.fetchPinnedMesssages();
          if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
            selected = state.selected;
          } else {
            selected = 0;
          }
          messages.isNotEmpty && !state.isUnpinAll
              ? emit(state.copyWith(
                  newPinnedMesssageStatus: PinnedMessageStatus.finished,
                  newPinnedMessageList: messages,
                  newSelected: selected,
                  newIsUnpinAll: false))
              : emit(PinnedMessageState(
                  pinnedMesssageStatus: PinnedMessageStatus.init));

          break;
        case ResourceAction.event:
          break;
      }
    }
  }
}
