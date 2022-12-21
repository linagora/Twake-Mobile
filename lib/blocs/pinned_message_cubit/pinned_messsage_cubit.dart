import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/services/socketio_service.dart';
import 'package:twake/services/synchronization_service.dart';

part 'pinned_messsage_state.dart';

class PinnedMessageCubit extends Cubit<PinnedMessageState> {
  late final MessagesRepository _messageRepository;

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
    emit(PinnedMessageState(pinnedMesssageStatus: PinnedMessageStatus.init));
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
          newSelectedChatMessageIndex: state.selectedChatMessageIndex,
          newSelected: state.selected,
          newIsUnpinAll: state.isUnpinAll));
    } else
      return;
  }

  bool selectPinnedMessage() {
    if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
      final messages = state.pinnedMessageList;

      final selected =
          messages.length - 1 == state.selected ? 0 : state.selected + 1;

      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.selected,
          newPinnedMessageList: messages,
          newSelected: selected,
          newSelectedChatMessageIndex: state.selectedChatMessageIndex,
          newIsUnpinAll: state.isUnpinAll));

      emit(state.copyWith(
          newPinnedMesssageStatus: PinnedMessageStatus.finished,
          newPinnedMessageList: messages,
          newSelected: selected,
          newSelectedChatMessageIndex: state.selectedChatMessageIndex,
          newIsUnpinAll: state.isUnpinAll));
      return true;
    }
    return false;
  }

  void jumpToPinnedMessage(Message message) async {
    final stateMessagesCubit = Get.find<ChannelMessagesCubit>().state;
    if (stateMessagesCubit is MessagesLoadSuccess) {
      // set isInHistory to false
      Get.find<ChannelMessagesCubit>().emit(MessagesLoadSuccess(
          messages: stateMessagesCubit.messages,
          hash: stateMessagesCubit.hash,
          isInHistory: false));

      // if message is in the state
      final messageRes = stateMessagesCubit.messages.firstWhereOrNull(
        (m) => m.id == message.id,
      );
      if (messageRes != null) {
        final res = stateMessagesCubit.messages.indexOf(messageRes);
        emit(state.copyWith(
            newSelectedChatMessageIndex: res,
            newPinnedMesssageStatus: state.pinnedMesssageStatus));
      } else {
        // if the message is not in the state, we need to fetch it

        final messagesAround = await Get.find<ChannelMessagesCubit>()
            .getMessagesAroundSelectedMessage(
                message: message, isDirect: false);
        final messagesCubit =
            Get.find<ChannelMessagesCubit>().state as MessagesLoadSuccess;
        final messageRes = messagesCubit.messages.firstWhereOrNull(
          (m) => m.id == message.id,
        );
        if (messageRes != null) {
          final res = messagesAround.indexOf(messageRes);
          if (res != -1)
            emit(state.copyWith(
                newSelectedChatMessageIndex: res,
                newPinnedMesssageStatus: state.pinnedMesssageStatus));
        }
      }
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
          newSelectedChatMessageIndex: state.selectedChatMessageIndex,
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
        emit(
            PinnedMessageState(pinnedMesssageStatus: PinnedMessageStatus.init));
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
            newSelectedChatMessageIndex: state.selectedChatMessageIndex,
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

          final List<Message> messages =
              await _messageRepository.fetchPinnedMesssages();
          if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
            selected = state.selected;
          } else {
            selected = 0;
          }
          (messages.isNotEmpty || state.pinnedMessageList.isNotEmpty) &&
                  !state.isUnpinAll
              ? emit(state.copyWith(
                  newPinnedMesssageStatus: PinnedMessageStatus.finished,
                  newPinnedMessageList:
                      messages.isEmpty ? state.pinnedMessageList : messages,
                  newSelected: selected,
                  newSelectedChatMessageIndex: state.selectedChatMessageIndex,
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
