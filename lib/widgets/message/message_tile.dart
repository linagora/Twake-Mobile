import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/screens/thread_screen.dart';
import 'package:twake_mobile/utils/twacode.dart';
import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/common/reaction.dart';
import 'package:twake_mobile/widgets/message/message_edit_modal_sheet.dart';
import 'package:twake_mobile/widgets/message/message_modal_sheet.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isThread;
  MessageTile(this.message, {this.isThread: false});

  void onReply(context) {
    Navigator.of(context).pushNamed(ThreadScreen.route, arguments: {
      'channelId':
          Provider.of<MessagesProvider>(context, listen: false).channelId,
      'messageId': message.id,
    });
  }

  void onEdit(context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return MessageEditModalSheet(message);
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return MessageModalSheet(
                message,
                onReply: onReply,
                onEdit: onEdit,
              );
            });
      },
      onTap: isThread
          ? null
          : () {
              if (!isThread && message.responsesCount != null) {
                onReply(context);
              }
            },
      child: Container(
        width: Dim.maxScreenWidth,
        padding: EdgeInsets.only(
          left: Dim.wm2,
          right: Dim.wm2,
          bottom: Dim.hm2,
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageAvatar(message.sender.img),
              SizedBox(width: Dim.wm2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: Dim.widthPercent(83),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.sender.firstName != null
                              ? '${message.sender.firstName} ${message.sender.lastName}'
                              : message.sender.username,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Text(
                          ' - Online', // TODO figure out how to get status of user
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              isThread
                                  ? DateFormatter.getVerboseDateTime(
                                      message.creationDate)
                                  : DateFormatter.getVerboseTime(
                                      message.creationDate),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: Dim.heightMultiplier),
                      width: Dim.widthPercent(83),
                      child: Parser(message.content.prepared).render(context)
                      // child: Text(
                      //   message.content.originalStr ?? '',
                      //   softWrap: true,
                      //   style: Theme.of(context).textTheme.bodyText2,
                      // ),
                      ),
                  SizedBox(height: Dim.hm2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (message.reactions != null)
                        ...(message.reactions as Map<String, dynamic>)
                            .keys
                            .map((r) {
                          return Reaction(
                            r,
                            (message.reactions as Map<String, dynamic>)[r]
                                ['count'],
                          );
                        }),
                      if (message.responsesCount != null && !isThread)
                        Text(
                          'See all answers (${message.responsesCount})',
                          style: StylesConfig.miniPurple,
                        ),
                    ],
                  ),
                  // trailing: Text(
                  // DateFormatter.getVerboseDateTime(message.creationDate),
                  // style: Theme.of(context).textTheme.subtitle2,
                  // ),
                ],
              ),
            ]),
      ),
    );
  }
}
