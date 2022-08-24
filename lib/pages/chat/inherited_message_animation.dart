import 'package:flutter/widgets.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';


// use inherited widget to pass messageAnimationCubit down the tree when needed
// dont use Get.put in home_binding, because when user use long press message then leave chat immediately, the animation still not end, when user come back to chat
// so MessageAnimationCubit should be discarded when not needed
class InheritedMessageAnimationCubit extends InheritedWidget {
  final MessageAnimationCubit messageAnimationCubit;
  InheritedMessageAnimationCubit(
      {required this.messageAnimationCubit, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedMessageAnimationCubit oldWidget) {
    return true;
  }
}