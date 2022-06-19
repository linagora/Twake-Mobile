part of 'pinned_messsage_cubit.dart';

enum PinnedMessageStatus { init, loading, finished, selected, failed }

class PinnedMessageState extends Equatable {
  final PinnedMessageStatus pinnedMesssageStatus;
  final List<Message> pinnedMessageList;
  final int selected;

  const PinnedMessageState(
      {this.pinnedMesssageStatus = PinnedMessageStatus.init,
      this.pinnedMessageList = const [],
      this.selected = 0});

  PinnedMessageState copyWith(
      {PinnedMessageStatus? newPinnedMesssageStatus,
      List<Message>? newPinnedMessageList,
      int? newSelected}) {
    return PinnedMessageState(
        pinnedMesssageStatus:
            newPinnedMesssageStatus ?? this.pinnedMesssageStatus,
        pinnedMessageList: newPinnedMessageList ?? this.pinnedMessageList,
        selected: newSelected ?? this.selected);
  }

  @override
  List<Object?> get props =>
      [pinnedMesssageStatus, pinnedMessageList, selected];
}

class MessagesAroundSelectedMessageFailed extends PinnedMessageState {
  final PinnedMessageStatus pinnedMesssageStatus;
  final List<Message> pinnedMessageList;

  MessagesAroundSelectedMessageFailed(
      {required this.pinnedMesssageStatus, required this.pinnedMessageList});
  @override
  List<Object?> get props => [pinnedMesssageStatus, pinnedMessageList];
}

class MessagesAroundSelectecMessageSuccess extends PinnedMessageState {
  final PinnedMessageStatus pinnedMesssageStatus;
  final List<Message> pinnedMessageList;
  final int selected;
  final List<Message> messagesAround;

  MessagesAroundSelectecMessageSuccess(
      {required this.pinnedMesssageStatus,
      required this.pinnedMessageList,
      required this.selected,
      required this.messagesAround});

  @override
  List<Object?> get props =>
      [pinnedMesssageStatus, pinnedMessageList, selected, messagesAround];
}
