part of 'message_animation_cubit.dart';

abstract class MessageAnimationState extends Equatable {
  const MessageAnimationState();
}

class MessageAnimationInitial extends MessageAnimationState {
  const MessageAnimationInitial();

  @override
  List<Object?> get props => [];
}

class MessageAnimationStart extends MessageAnimationState {
  final Message longPressMessage;
  final int longPressIndex;
  final ItemPositionsListener itemPositionListener;
  final BuildContext messagesListContext;

  MessageAnimationStart(
      {required this.longPressMessage,
        required this.longPressIndex,
        required this.itemPositionListener,
        required this.messagesListContext});

  @override
  List<Object?> get props =>
      [longPressMessage, longPressIndex, itemPositionListener];
}

class MessageAnimationEnd extends MessageAnimationState {
  const MessageAnimationEnd();

  @override
  List<Object?> get props => [];
}

class MessageAnimationOpenEmojiBoard extends MessageAnimationEnd {
  final Message longPressMessage;

  const MessageAnimationOpenEmojiBoard({required this.longPressMessage});

  @override
  List<Object?> get props => [longPressMessage];
}
