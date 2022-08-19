import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/models/message/message.dart';

import 'message_animation_state.dart';

class MessageAnimationCubit extends Cubit<MessageAnimationState> {
  MessageAnimationCubit() : super(MessageAnimationInitial());

  void startAnimation({
    required Message longPressMessage,
    required int longPressIndex,
    required ItemPositionsListener itemPositionsListener,
  }) {
    emit(MessageAnimationStart(
      longPressMessage: longPressMessage,
      longPressIndex: longPressIndex,
      itemPositionListener: itemPositionsListener,
    ));
  }

  void endAnimation() {
    emit(MessageAnimationEnd());
  }
}
