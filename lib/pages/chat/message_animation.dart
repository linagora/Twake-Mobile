import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/animated_menu_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LongPressMessageAnimation<T extends BaseMessagesCubit>
    extends StatelessWidget {
  final GlobalKey messagesListKey;
  final bool isDirect;

  LongPressMessageAnimation(
      {required this.messagesListKey, required this.isDirect});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageAnimationCubit, MessageAnimationState>(
      bloc: Get.find<MessageAnimationCubit>(),
      builder: ((context, state) {
        if (state is! MessageAnimationStart) {
          return Container();
        }

        // find size of messages list
        Size? size;
        Offset? messageListTopLeftPoint;
        if (messagesListKey.currentContext != null &&
            messagesListKey.currentContext?.findRenderObject() != null) {
          size =
              (messagesListKey.currentContext?.findRenderObject() as RenderBox)
                  .size;
          messageListTopLeftPoint =
              (messagesListKey.currentContext?.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);
        }

        return MenuMessageDropDown<T>(
          message: state.longPressMessage,
          itemPositionsListener: state.itemPositionListener,
          clickedItem: state.longPressIndex,
          messagesListSize: size,
          messageListPosition: messageListTopLeftPoint,
          onReply: () {
            Get.find<MessageAnimationCubit>().endAnimation();

            NavigatorService.instance.navigate(
              channelId: state.longPressMessage.channelId,
              threadId: state.longPressMessage.id,
              reloadThreads: false,
            );
          },
          onEdit: () {
            Get.find<MessageAnimationCubit>().endAnimation();

            Get.find<T>().startEdit(message: state.longPressMessage);
          },
          onCopy: () {
            Get.find<MessageAnimationCubit>().endAnimation();

            FlutterClipboard.copy(state.longPressMessage.text);

            Utilities.showSimpleSnackBar(
                message: AppLocalizations.of(context)!.messageCopiedInfo,
                context: context,
                iconData: Icons.copy);
          },
          onDelete: () {
            Get.find<MessageAnimationCubit>().endAnimation();
            Get.find<T>().delete(message: state.longPressMessage);
          },
          onPinMessage: () {
            Get.find<MessageAnimationCubit>().endAnimation();

            Get.find<PinnedMessageCubit>().pinMessage(
                message: state.longPressMessage, isDirect: isDirect);
          },
          onUnpinMessage: () async {
            final bool result = await Get.find<PinnedMessageCubit>()
                .unpinMessage(message: state.longPressMessage);
            if (!result)
              Utilities.showSimpleSnackBar(
                  context: context,
                  message: AppLocalizations.of(context)!.somethingWentWrong);
          },
        );
      }),
    );
  }
}
