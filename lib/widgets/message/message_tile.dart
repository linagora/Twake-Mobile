import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/blocs/user_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/widgets/message/twacode.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/reaction.dart';

import 'package:twake/widgets/message/message_modal_sheet.dart';

class MessageTile<T extends BaseChannelBloc> extends StatelessWidget {
  final bool hideShowAnswers;
  final Message message;

  MessageTile({
    this.message,
    this.hideShowAnswers: false,
    Key key,
  }) : super(key: key);

  void onReply(context, String messageId, {bool autofocus: false}) {
    BlocProvider.of<MessagesBloc<T>>(context).add(SelectMessage(messageId));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreadPage<T>(
          autofocus: autofocus,
        ),
      ),
    );
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
    if (message.threadId == null)
      BlocProvider.of<MessagesBloc<T>>(context).add(event);
    else
      BlocProvider.of<ThreadsBloc<T>>(context).add(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SingleMessageBloc>(
        create: (_) => SingleMessageBloc(message),
        child: BlocBuilder<SingleMessageBloc, SingleMessageState>(
          builder: (ctx, messageState) {
            if (messageState is MessageReady)
              return InkWell(
                onLongPress: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) {
                        return MessageModalSheet(
                          userId: messageState.userId,
                          messageId: messageState.id,
                          responsesCount: messageState.responsesCount,
                          isThread: messageState.threadId != null,
                          onReply: onReply,
                          ctx: ctx,
                          onDelete: (ctx) => onDelete(
                              ctx,
                              RemoveMessage(
                                channelId: message.channelId,
                                messageId: messageState.id,
                                threadId: messageState.threadId,
                              )),
                          onCopy: () {
                            print('TEXT: ${messageState.text}');
                            onCopy(context: ctx, text: messageState.text);
                          },
                        );
                      });
                },
                onTap: () {
                  FocusManager.instance.primaryFocus.unfocus();
                  if (messageState.threadId == null &&
                      messageState.responsesCount != 0) {
                    onReply(context, messageState.id);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    bottom: 12.0,
                  ),
                  child: BlocProvider<UserBloc>(
                    create: (_) => UserBloc(messageState.userId),
                    child: BlocBuilder<UserBloc, UserState>(
                        builder: (_, state) {
                          if (state is UserReady) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  children: [
                                    if (state is UserReady)
                                      ImageAvatar(
                                      state.thumbnail,
                                      width: 30,
                                      height: 30,
                                    ),
                                    if (state is !UserReady)
                                      CircularProgressIndicator(),
                                  ],
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${state.firstName} ${state.lastName}',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff444444),
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                          Text(
                                            messageState.threadId != null
                                                ? DateFormatter.getVerboseDateTime(
                                                messageState.creationDate)
                                                : DateFormatter.getVerboseTime(
                                                messageState.creationDate),
                                            style: TextStyle(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff92929C),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.0),
                                      Parser(messageState.content, messageState.charCount)
                                          .render(context),
                                      SizedBox(height: 5.0),
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
                                              messageState.threadId == null &&
                                              !hideShowAnswers)
                                            Text(
                                              'See all answers (${messageState.responsesCount})',
                                              style: StylesConfig.miniPurple,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                    }
                  ),
                ),
              )); else
              return CircularProgressIndicator();
          },
        ));
  }
}
