import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/animated_menu_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/widgets/common/drop_down_bar.dart';
import 'package:twake/widgets/common/emoji_board.dart';
import 'package:twake/widgets/message/emoji_set.dart';

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
        if (state is MessageAnimationOpenEmojiBoard) {
          return Container(
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.bottomCenter,
            child: EmojiBoard(
                onEmojiSelected: (String emojiCode) =>
                    _onEmojiSelected(state.longPressMessage, emojiCode)),
          );
        }

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
          lowerWidget: LongPressMenuBar<T>(
            message: state.longPressMessage,
            isDirect: isDirect,
          ),
          lowerWidgetHeight: LongPressMenuBar.height,
          upperWidget: EmojiLine(
            onEmojiSelected: (String emojiCode) {
              _onEmojiSelected(state.longPressMessage, emojiCode);
            },
            message: state.longPressMessage,
          ),
          upperWidgetHeight: 50,
        );
      }),
    );
  }

  _onEmojiSelected(Message message, String emojiCode) async {
    await Get.find<T>().react(message: message, reaction: emojiCode);
    Future.delayed(
      Duration(milliseconds: 50),
      FocusManager.instance.primaryFocus?.unfocus,
    );
  }
}

class LongPressMenuBar<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final bool isDirect;

  // because currently we cant get the size of this widget when it's not build,
  // so we have to precalculate height of this widget first
  static final double height = (DropDownButton.DROPDOWN_HEIGHT +
          DropDownButton.DROPDOWN_PADDING_TOP * 2 +
          DropDownButton.DROPDOWN_SEPARATOR_HEIGHT) *
      5;

  const LongPressMenuBar({
    required this.message,
    this.isDirect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropDownButton(
          text: AppLocalizations.of(context)!.reply,
          imagePath: imageComment,
          isTop: true,
          onClick: () async {
            Get.find<MessageAnimationCubit>().endAnimation();

            await NavigatorService.instance.navigate(
              channelId: message.channelId,
              threadId: message.id,
              reloadThreads: false,
            );
          },
        ),
        if (message.isOwnerMessage) ...[
          DropDownButton(
            text: AppLocalizations.of(context)!.edit,
            imagePath: imageEdit,
            onClick: () {
              Get.find<MessageAnimationCubit>().endAnimation();

              Get.find<T>().startEdit(message: message);
            },
          )
        ],
        DropDownButton(
          text: AppLocalizations.of(context)!.copy,
          imagePath: imageCopy,
          onClick: () async {
            Get.find<MessageAnimationCubit>().endAnimation();

            await FlutterClipboard.copy(message.text);

            Utilities.showSimpleSnackBar(
                message: AppLocalizations.of(context)!.messageCopiedInfo,
                context: context,
                iconData: Icons.copy);
          },
        ),
        DropDownButton(
          text: AppLocalizations.of(context)!.pinMesssage,
          imagePath: imagePinAction,
          isSecondBottom: !message.isOwnerMessage,
          onClick: () async {
            Get.find<MessageAnimationCubit>().endAnimation();

            await Get.find<PinnedMessageCubit>()
                .pinMessage(message: message, isDirect: isDirect);
          },
        ),
        DropDownButton(
          text: AppLocalizations.of(context)!.unpinMesssage,
          isBottom: !message.isOwnerMessage,
          imagePath: imageUnpinAction,
          isSecondBottom: message.isOwnerMessage,
          onClick: () async {
            Get.find<MessageAnimationCubit>().endAnimation();

            final bool result = await Get.find<PinnedMessageCubit>()
                .unpinMessage(message: message);
            if (!result)
              Utilities.showSimpleSnackBar(
                  context: context,
                  message: AppLocalizations.of(context)!.somethingWentWrong);
          },
        ),
        if (message.isOwnerMessage) ...[
          DropDownButton(
            isBottom: true,
            text: AppLocalizations.of(context)!.delete,
            imagePath: imageDeleteAction,
            textColor: Colors.red,
            iconColor: Colors.red,
            onClick: () async {
              Get.find<MessageAnimationCubit>().endAnimation();
              await Get.find<T>().delete(message: message);
            },
          )
        ],
      ],
    );
  }
}
