import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_state.dart';
import 'package:twake/models/message/message.dart';

abstract class BaseUnreadMessagesCubit extends Cubit<UnreadMessagesState> {
  late final BaseChannelsCubit _channelsCubit;

  BaseUnreadMessagesCubit({BaseChannelsCubit? channelsCubit})
      : super(UnreadMessagesInitial()) {
    if (channelsCubit == null) {
      channelsCubit = ChannelsCubit();
    }
    _channelsCubit = channelsCubit;
  }

  void listenOwnerMessage() {
    emit(NoUnreadMessages());
  }

  fetchUnreadMessages(
      {required List<Message> messages, required bool isDirect});
  listenNotOwnerMessage();
}

class ChannelUnreadMessagesCubit extends BaseUnreadMessagesCubit {
  ChannelUnreadMessagesCubit(
      {ChannelsCubit? channelsCubit, DirectsCubit? directsCubit})
      : super(channelsCubit: channelsCubit) {
    this._directsCubit = directsCubit;
  }

  DirectsCubit? _directsCubit;

  void fetchUnreadMessages({
    required List<Message> messages,
    required bool isDirect,
  }) {
    int userLastAccess = 0;
    if (isDirect) {
      userLastAccess = _directsCubit!.selectedChannel?.userLastAccess ?? 0;
    } else {
      userLastAccess = _channelsCubit.selectedChannel?.userLastAccess ?? 0;
    }

    messages.sort((a, b) => a.createdAt
        .compareTo(b.createdAt)); // sort message from oldest to latest

    Iterable<Message> unreadMessages =
        messages.where((message) => message.createdAt > userLastAccess);

    // get number of unread messages
    int unreadCounter = 0;

    unreadCounter = unreadMessages.length;

    // contain unread Thread from oldest to latest
    final firstUnreadMsgThread;
    final unreadThreads = messages
        .where((message) =>
            message.responsesCount > 0 &&
            message.lastReplies!.isNotEmpty &&
            message.lastReply!.createdAt > userLastAccess)
        .toList();

    if (unreadMessages.isEmpty && unreadThreads.isEmpty) {
      emit(NoUnreadMessages());
      return;
    }
    // when there are unread messages in channel
    if (unreadMessages.isNotEmpty) {
      emit(UnreadMessagesFound(
          unreadCounter: unreadCounter, userLastAccess: userLastAccess));
    }

    if (unreadThreads.isNotEmpty) {
      // when there are only messages in thread or first unread message in thread
      if (unreadMessages.isEmpty ||
          unreadThreads.first.lastReply!.createdAt <
              unreadMessages.first.createdAt) {
        firstUnreadMsgThread = unreadThreads.first;
      } else {
        firstUnreadMsgThread = null;
      }
      // if first unread message in thread, emit with firstUnreadThread
      emit(UnreadMessagesThreadFound(
          unreadCounter: unreadCounter,
          unreadThreads: unreadThreads,
          userLastAccess: userLastAccess,
          firstUnreadThread: firstUnreadMsgThread));
    }
  }

  void listenNotOwnerMessage() {
    if (state is UnreadMessagesFound) {
      final currentState = state as UnreadMessagesFound;
      emit(UnreadMessagesFound(
          unreadCounter: currentState.unreadCounter + 1,
          userLastAccess: currentState.userLastAccess));
    }
  }
}

class ThreadUnreadMessagesCubit extends BaseUnreadMessagesCubit {
  late final _channelUnreadMessagesCubit;
  // for tracking last access to thread of each unread threads
  late Map<String, int> userLastAccessThreads;

  ThreadUnreadMessagesCubit(
      {required ChannelUnreadMessagesCubit channelUnreadMessagesCubit,
      required ChannelsCubit channelsCubit})
      : super(channelsCubit: channelsCubit) {
    _channelUnreadMessagesCubit = channelUnreadMessagesCubit;
    userLastAccessThreads = Map();
  }

  void listenOwnerMessage() {
    super.listenOwnerMessage();
  }

  void listenNotOwnerMessage() {
    if (state is UnreadMessagesThreadFound) {
      final currentState = state as UnreadMessagesThreadFound;
      emit(UnreadMessagesThreadFound(
        unreadCounter: currentState.unreadCounter + 1,
        userLastAccess: currentState.userLastAccess,
        unreadThreads: currentState.unreadThreads,
        firstUnreadThread: currentState.firstUnreadThread,
      ));
    }
  }

  void fetchUnreadMessages(
      {required List<Message> messages, required bool isDirect}) async {
    if (_channelUnreadMessagesCubit.state is UnreadMessagesThreadFound) {
      final currentState =
          _channelUnreadMessagesCubit.state as UnreadMessagesThreadFound;
      var userLastAccess = currentState.userLastAccess;

      // if this is not first time enter thread
      final repliedMessage = messages.first;
      userLastAccess = userLastAccessThreads.putIfAbsent(
          repliedMessage.id, () => userLastAccess);

      //fetch messsage in thread first
      int unreadCounter = messages
          .where((message) => message.createdAt > userLastAccess)
          .length;
      if (repliedMessage.createdAt > userLastAccess && unreadCounter != null) {
        unreadCounter = unreadCounter - 1;
      }

      if (messages.isNotEmpty) {
        userLastAccessThreads[repliedMessage.id] = messages.last.createdAt;
      }

      emit(UnreadMessagesThreadFound(
        unreadCounter: unreadCounter,
        userLastAccess: userLastAccess,
        unreadThreads: currentState.unreadThreads,
        firstUnreadThread: currentState.firstUnreadThread,
      ));
    } else {
      emit(NoUnreadMessages());
    }
  }
}
