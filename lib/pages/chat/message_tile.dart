import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_content.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';

class MessageTile<T extends BaseMessagesCubit> extends StatefulWidget {
  final Message message;
  final bool hideSender;
  final bool isDirect;
  final bool isThread;
  final bool isSenderHidden;
  final bool isHeadInThred;
  MessageTile({
    required this.message,
    this.hideSender = false,
    this.isDirect = false,
    this.isThread = false,
    this.isSenderHidden = false,
    this.isHeadInThred = false,
    Key? key,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState<T>();
}

class _MessageTileState<T extends BaseMessagesCubit>
    extends State<MessageTile> {
  @override
  void initState() {
    super.initState();
  }

  void onReply(Message message) {
    NavigatorService.instance.navigate(
      channelId: message.channelId,
      threadId: message.id,
      reloadThreads: false,
    );
  }

  void onEdit(Message message) {
    message.inThread
        ? Get.find<ThreadMessagesCubit>().startEdit(message: widget.message)
        : Get.find<ChannelMessagesCubit>().startEdit(message: widget.message);
    Navigator.of(context).pop();
  }

  void onDelete() {
    widget.isThread
        ? Get.find<ThreadMessagesCubit>().delete(message: widget.message)
        : Get.find<ChannelMessagesCubit>().delete(message: widget.message);
    Navigator.of(context).pop();
  }

  void onCopy(context, text) {
    FlutterClipboard.copy(text);

    Utilities.showSimpleSnackBar(
        message: AppLocalizations.of(context)!.messageCopiedInfo,
        context: context,
        iconData: Icons.copy);

    Navigator.of(context).pop();
  }

  void onPinMessage() async {
    Get.find<PinnedMessageCubit>()
        .pinMessage(message: widget.message, isDirect: widget.isDirect);
    Navigator.of(context).pop();
  }

  void onUnpinMessage() async {
    final bool result = await Get.find<PinnedMessageCubit>()
        .unpinMessage(message: widget.message);
    Navigator.of(context).pop();
    if (!result)
      Utilities.showSimpleSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.somethingWentWrong);
  }

  @override
  Widget build(BuildContext context) {
    bool _isMyMessage = widget.message.userId == Globals.instance.userId;
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
        if (widget.message.responsesCount != 0) {
          onReply(widget.message);
        }
      },
      onLongPress: () {
        if (widget.message.subtype != MessageSubtype.deleted &&
            widget.message.delivery == Delivery.delivered)
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) {
              return MessageModalSheet<T>(
                message: widget.message,
                ctx: context,
                isMe: _isMyMessage,
                isThread: widget.isThread,
                onReply: onReply,
                onEdit: onEdit,
                onDelete: onDelete,
                onCopy: onCopy,
                onPinMessage: onPinMessage,
                onUnpinMessage: onUnpinMessage,
              );
            },
          );
      },
      child: _messagePadding(_isMyMessage),
    );
  }

  Widget _messagePadding(bool _isMyMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            _isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          SizedBox(
            width: _isMyMessage ? Dim.widthPercent(3) : Dim.widthPercent(2),
          ),
          MessageContent(
            message: widget.message,
            isThread: widget.isThread,
            isHeadInThred: widget.isHeadInThred,
            isDirect: widget.isDirect,
            isMyMessage: _isMyMessage,
            isSenderHidden: widget.isSenderHidden,
            key: ValueKey(widget.message.hashCode),
          ),
          SizedBox(
            width: _isMyMessage ? Dim.widthPercent(3) : Dim.widthPercent(7),
          ),
        ],
      ),
    );
  }
}
