import 'package:flutter/material.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_content.dart';
import 'package:twake/services/navigator_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
        if (widget.message.responsesCount != 0) {
          onReply(widget.message);
        }
      },
      child: _messagePadding(),
    );
  }

  Widget _messagePadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: widget.message.isOwnerMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
            isHeadInThred: widget.isHeadInThred,
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
    );
  }
}
