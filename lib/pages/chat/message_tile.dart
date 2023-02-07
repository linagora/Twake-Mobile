import 'package:flutter/material.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_content.dart';
import 'package:twake/services/navigator_service.dart';

class MessageTile<T extends BaseMessagesCubit> extends StatefulWidget {
  final Message message;
  final bool isDirect;
  final bool isThread;
  final bool isSenderHidden;
  final bool isHeadInThread;
  MessageTile({
    required this.message,
    this.isDirect = false,
    this.isThread = false,
    this.isSenderHidden = false,
    this.isHeadInThread = false,
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
    if (Globals.instance.channelId != null) {
      NavigatorService.instance.navigateToThread(
        channelId: Globals.instance.channelId!,
        threadId: message.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
        if (widget.message.responsesCount != 0) {
          onReply(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: widget.message.files == null
                  ? widget.message.isOwnerMessage
                      ? Dim.widthPercent(3)
                      : Dim.widthPercent(2)
                  : widget.message.isOwnerMessage
                      ? Dim.widthPercent(15)
                      : Dim.widthPercent(1),
            ),
            MessageContent(
              message: widget.message,
              isThread: widget.isThread,
              isHeadInThread: widget.isHeadInThread,
              isDirect: widget.isDirect,
              isSenderHidden: widget.isSenderHidden,
              key: ValueKey(widget.message.hashCode),
            ),
            SizedBox(
              width: widget.message.files == null
                  ? widget.message.isOwnerMessage
                      ? Dim.widthPercent(3)
                      : Dim.widthPercent(7)
                  : widget.message.isOwnerMessage
                      ? Dim.widthPercent(3)
                      : Dim.widthPercent(5),
            ),
          ],
        ),
      ),
    );
  }
}
