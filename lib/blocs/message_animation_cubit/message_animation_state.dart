import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/models/message/message.dart';

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
