import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/message.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/services/dateformatter.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/reaction.dart';

// import 'package:twake/widgets/message/message_edit_modal_sheet.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';
import 'package:logger/logger.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isThread;

  MessageTile(this.message, {this.isThread: false, Key key}) : super(key: key);

  void onReply(context) {
    Navigator.of(context).pushNamed(ThreadScreen.route, arguments: {
      'channelId':
          Provider.of<MessagesProvider>(context, listen: false).channelId,
      'messageId': message.id,
    });
  }

  onCopy(context) {
    FlutterClipboard.copy(message.content.originalStr);
    Navigator.of(context).pop();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1300),
        content: Text('Message has been copied to clipboard'),
      ),
    );
  }

  void onDelete(context) {
    Navigator.of(context).pop();
    final logger = Logger();
    logger.d('Removing message ${message.toJson()}');
    Provider.of<MessagesProvider>(context, listen: false).removeMessage(
      message.id,
      threadId: message.threadId,
    );
  }

  // NOT IMPLEMENTED YET
  // void onEdit(context) {
  // Navigator.of(context).pop();
  // showModalBottomSheet(
  // context: context,
  // builder: (context) {
  // return MessageEditModalSheet(message);
  // });
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return MessageModalSheet(
                message,
                isThread: isThread,
                onReply: onReply,
                onDelete: onDelete,
                onCopy: () {
                  onCopy(context);
                },
              );
            });
      },
      onTap: () {
        FocusManager.instance.primaryFocus.unfocus();
        if (!isThread &&
            message.responsesCount != null &&
            message.responsesCount != 0) {
          onReply(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: Dim.wm4,
          right: Dim.wm4,
          bottom: Dim.heightMultiplier,
        ),
        child: Consumer<Message>(
          builder: (_, message, c) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: ImageAvatar(message.sender.thumbnail),
                  title: Text(
                    message.sender.firstName != null
                        ? '${message.sender.firstName} ${message.sender.lastName}'
                        : message.sender.username,
                    style: Theme.of(context).textTheme.bodyText1,
                    overflow: TextOverflow.fade,
                  ),
                  subtitle: Text(
                    isThread
                        ? DateFormatter.getVerboseDateTime(message.creationDate)
                        : DateFormatter.getVerboseTime(message.creationDate),
                    style: Theme.of(context).textTheme.subtitle2,
                  )),
              Parser(
                message.content.prepared,
                (message.content.originalStr ?? '').length,
              ).render(context),
              SizedBox(height: Dim.tm2()),
              Wrap(
                runSpacing: Dim.heightMultiplier,
                crossAxisAlignment: WrapCrossAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  if (message.reactions != null)
                    ...message.reactions.keys.map((r) {
                      return Reaction(
                        r,
                        message.reactions[r]['count'],
                      );
                    }),
                  if (message.responsesCount != null &&
                      message.responsesCount != 0 &&
                      !isThread)
                    Text(
                      'See all answers (${message.responsesCount})',
                      style: StylesConfig.miniPurple,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
