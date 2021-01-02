import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/blocs/user_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/widgets/message/twacode.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/reaction.dart';

import 'package:twake/widgets/message/message_modal_sheet.dart';

class MessageTile extends StatelessWidget {
  MessageTile();

  void onReply(context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ThreadPage()));
  }

  onCopy({context, text}) {
    FlutterClipboard.copy(text);
    Navigator.of(context).pop();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1300),
        content: Text('Message has been copied to clipboard'),
      ),
    );
  }

  void onDelete(context, RemoveMessage event) {
    BlocProvider.of<MessagesBloc>(context).add(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleMessageBloc, SingleMessageState>(
      builder: (ctx, messageState) {
        if (messageState is MessageReady)
          return InkWell(
            onLongPress: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) {
                    return MessageModalSheet(
                      userId: messageState.userId,
                      responsesCount: messageState.responsesCount,
                      isThread: messageState.threadId != null,
                      onReply: onReply,
                      onDelete: (ctx) => onDelete(
                          ctx,
                          RemoveMessage(
                            messageId: messageState.id,
                            threadId: messageState.threadId,
                          )),
                      onCopy: () {
                        onCopy(context: ctx, text: messageState.text);
                      },
                    );
                  });
            },
            onTap: () {
              FocusManager.instance.primaryFocus.unfocus();
              if (messageState.threadId == null &&
                  messageState.responsesCount != 0) {
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
                    create: (_) => UserBloc(messageState.userId),
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (_, state) {
                        if (state is UserReady)
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: ImageAvatar(state.thumbnail),
                            title: Text(
                              '${state.firstName} ${state.lastName}',
                              style: Theme.of(context).textTheme.bodyText1,
                              overflow: TextOverflow.fade,
                            ),
                            subtitle: Text(
                              messageState.threadId != null
                                  ? DateFormatter.getVerboseDateTime(
                                      messageState.creationDate)
                                  : DateFormatter.getVerboseTime(
                                      messageState.creationDate),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          );
                        else
                          return CircularProgressIndicator();
                      },
                    ),
                  ),
                  Parser(messageState.content, messageState.charCount)
                      .render(context),
                  SizedBox(height: Dim.tm2()),
                  Wrap(
                    runSpacing: Dim.heightMultiplier,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: [
                      ...messageState.reactions.keys.map((r) {
                        return Reaction(
                          r,
                          messageState.reactions[r]['count'],
                        );
                      }),
                      if (messageState.responsesCount > 0 &&
                          messageState.threadId == null)
                        Text(
                          'See all answers (${messageState.responsesCount})',
                          style: StylesConfig.miniPurple,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        else
          return CircularProgressIndicator();
      },
    );
  }
}
