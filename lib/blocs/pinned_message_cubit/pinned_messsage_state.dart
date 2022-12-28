part of 'pinned_messsage_cubit.dart';

enum PinnedMessageStatus {
  init,
  loading,
  finished,
  jumpToPin,
  selected,
  failed
}

class PinnedMessageState extends Equatable {
  final PinnedMessageStatus pinnedMesssageStatus;
  final List<Message> pinnedMessageList;
  final int selected;
  final int selectedChatMessageIndex;
  final bool isUnpinAll;

  const PinnedMessageState({
    this.pinnedMesssageStatus = PinnedMessageStatus.init,
    this.pinnedMessageList = const [],
    this.selected = 0,
    this.selectedChatMessageIndex = -1,
    this.isUnpinAll = false,
  });

  PinnedMessageState copyWith(
      {PinnedMessageStatus? newPinnedMesssageStatus,
      List<Message>? newPinnedMessageList,
      int? newSelected,
      int? newSelectedChatMessageIndex,
      bool? newIsUnpinAll}) {
    return PinnedMessageState(
        pinnedMesssageStatus:
            newPinnedMesssageStatus ?? this.pinnedMesssageStatus,
        pinnedMessageList: newPinnedMessageList ?? this.pinnedMessageList,
        selected: newSelected ?? this.selected,
        selectedChatMessageIndex:
            newSelectedChatMessageIndex ?? this.selectedChatMessageIndex,
        isUnpinAll: newIsUnpinAll ?? this.isUnpinAll);
  }

  @override
  List<Object?> get props => [
        pinnedMesssageStatus,
        pinnedMessageList,
        selected,
        selectedChatMessageIndex,
        isUnpinAll
      ];
}
