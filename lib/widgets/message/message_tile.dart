import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/user_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/message.dart';
import 'package:twake/pages/routes.dart';
import 'package:twake/widgets/message/twacode.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/reaction.dart';

import 'package:twake/widgets/message/message_modal_sheet.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isThread;

  MessageTile(this.message, {this.isThread: false, Key key}) : super(key: key);

  void onReply(context) {
    Navigator.of(context).pushNamed(Routes.thread);
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
    BlocProvider.of<MessagesBloc>(context).add(RemoveMessage(
      messageId: message.id,
      threadId: message.threadId,
      channelId: message.channelId,
    ));
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocProvider<UserBloc>(
              create: (_) => UserBloc(message.userId),
              child: BlocBuilder<UserBloc, UserState>(
                builder: (_, state) {
                  UserReady user = state;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: ImageAvatar(user.thumbnail),
                    title: Text(
                      '${user.firstName} ${user.lastName}',
                      style: Theme.of(context).textTheme.bodyText1,
                      overflow: TextOverflow.fade,
                    ),
                    subtitle: Text(
                      isThread
                          ? DateFormatter.getVerboseDateTime(
                              message.creationDate)
                          : DateFormatter.getVerboseTime(message.creationDate),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  );
                },
              ),
            ),
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
    );
  }
}
