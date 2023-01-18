import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/message/message.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'message_animation_state.dart';

class MessageAnimationCubit extends Cubit<MessageAnimationState> {
  MessageAnimationCubit() : super(MessageAnimationInitial());

  void resetAnimation() {
    emit(MessageAnimationInitial());
  }

  void startAnimation({
    required BuildContext messagesListContext,
    required Message longPressMessage,
    required int longPressIndex,
    required ItemPositionsListener itemPositionsListener,
  }) {
    emit(MessageAnimationStart(
      messagesListContext: messagesListContext,
      longPressMessage: longPressMessage,
      longPressIndex: longPressIndex,
      itemPositionListener: itemPositionsListener,
    ));
  }

  void endAnimation() {
    emit(MessageAnimationEnd());
  }

  void openEmojiBoard(Message longPressMessage) {
    emit(MessageAnimationOpenEmojiBoard(longPressMessage: longPressMessage));
  }
}
