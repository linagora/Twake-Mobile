import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/blocs/quote_message_cubit/quote_message_cubit.dart';
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
  final bool isDirect;

  LongPressMessageAnimation({required this.isDirect});

  @override
  Widget build(BuildContext context) {
    // don't use get.put in home_binding because when you leave the chat, messageAnimationCubit should be back to initialState
    return BlocBuilder<MessageAnimationCubit, MessageAnimationState>(
      bloc: Get.find<MessageAnimationCubit>(),
      builder: ((context, state) {
        if (state is MessageAnimationOpenEmojiBoard) {
          return InkWell(
            onTapDown: (_) => Get.find<MessageAnimationCubit>().endAnimation(),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              alignment: Alignment.bottomCenter,
              child: EmojiBoard(
                  onEmojiSelected: (String emojiCode) =>
                      _onEmojiSelected(state.longPressMessage, emojiCode)),
            ),
          );
        }

        if (state is! MessageAnimationStart) {
          return Container();
        }

        // find size of messages list
        Size? size;
        Offset? messageListTopLeftPoint;
        RenderObject? renderObject =
            state.messagesListContext.findRenderObject();
        if (renderObject != null && (renderObject as RenderBox).hasSize) {
          size = renderObject.size;
          messageListTopLeftPoint = renderObject.localToGlobal(Offset.zero);

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
            lowerWidgetHeight: _getHeightMenuBar(state.longPressMessage),
            upperWidget: EmojiLine(
              onEmojiSelected: (String emojiCode) {
                _onEmojiSelected(state.longPressMessage, emojiCode);
              },
              message: state.longPressMessage,
            ),
            upperWidgetHeight: 50,
          );
        }

        return Container();
      }),
    );
  }

  _onEmojiSelected(Message message, String emojiCode) async {
    await Get.find<T>().react(message: message, reaction: emojiCode);
    Future.delayed(
      Duration(milliseconds: 50),
      FocusManager.instance.primaryFocus?.unfocus,
    );
    Get.find<MessageAnimationCubit>().endAnimation();
  }

  // because currently we cant get the size of this widget when it's not build,
  // so we have to precalculate height of this widget first
  double _getHeightMenuBar(Message message) {
    int countDropDown = 2;
    if (message.subtype != MessageSubtype.deleted && !message.inThread) {
      countDropDown++;
    }
    if (message.isOwnerMessage) {
      countDropDown++;
      if (message.responsesCount == 0) {
        countDropDown++;
      }
    }
    return (DropDownButton.DROPDOWN_HEIGHT +
            DropDownButton.DROPDOWN_PADDING_TOP * 2 +
            DropDownButton.DROPDOWN_SEPARATOR_HEIGHT) *
        countDropDown;
  }
}

class LongPressMenuBar<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final bool isDirect;

  const LongPressMenuBar({
    required this.message,
    required this.isDirect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (message.subtype != MessageSubtype.deleted && !message.inThread)
          DropDownButton(
            text: AppLocalizations.of(context)!.reply,
            imagePath: imageComment,
            isTop: true,
            onClick: () async {
              Get.find<MessageAnimationCubit>().endAnimation();
              isDirect
                  ? Get.find<QuoteMessageCubit>().addQuoteMessage(message)
                  : await NavigatorService.instance.navigateToThread(
                      channelId: message.channelId,
                      threadId: message.id,
                    );
            },
          ),
        if (message.isOwnerMessage)
          DropDownButton(
            isTop: message.inThread,
            text: AppLocalizations.of(context)!.edit,
            imagePath: imageEdit,
            onClick: () {
              Get.find<MessageAnimationCubit>().endAnimation();

              Get.find<T>().startEdit(message: message);
            },
          ),
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
        if (message.pinnedInfo == null)
          DropDownButton(
            text: AppLocalizations.of(context)!.pinMesssage,
            isBottom: !message.isOwnerMessage || message.responsesCount != 0,
            imagePath: imagePinAction,
            isSecondBottom: !message.isOwnerMessage,
            onClick: () async {
              Get.find<MessageAnimationCubit>().endAnimation();

              await Get.find<PinnedMessageCubit>()
                  .pinMessage(message: message, isDirect: isDirect);
            },
          ),
        if (message.pinnedInfo != null)
          DropDownButton(
            text: AppLocalizations.of(context)!.unpinMesssage,
            isBottom: !message.isOwnerMessage || message.responsesCount != 0,
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
        if (message.isOwnerMessage && message.responsesCount == 0)
          DropDownButton(
            isBottom: true,
            text: AppLocalizations.of(context)!.delete,
            imagePath: imageDeleteAction,
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
            onClick: () async {
              Get.find<MessageAnimationCubit>().endAnimation();
              await Get.find<T>().delete(message: message);
            },
          )
      ],
    );
  }
}
