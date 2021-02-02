import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/blocs/message_edit_bloc/message_edit_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc/single_message_bloc.dart';
import 'package:twake/blocs/threads_bloc/threads_bloc.dart';
// import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/repositories/draft_repository.dart';
// import 'package:twake/widgets/message/twacode.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';

class MessageTile<T extends BaseChannelBloc> extends StatefulWidget {
  final bool hideShowAnswers;
  final Message message;

  MessageTile({
    this.message,
    this.hideShowAnswers: false,
    Key key,
  }) : super(key: key);

  @override
  _MessageTileState<T> createState() => _MessageTileState<T>();
}

class _MessageTileState<T extends BaseChannelBloc>
    extends State<MessageTile<T>> {
  bool _hideShowAnswers;
  Message _message;

  @override
  void initState() {
    super.initState();
    _hideShowAnswers = widget.hideShowAnswers;
    _message = widget.message;
  }

  void onReply(context, String messageId, {bool autofocus: false}) {
    BlocProvider.of<MessagesBloc<T>>(context).add(SelectMessage(messageId));
    BlocProvider.of<DraftBloc>(context)
        .add(LoadDraft(id: _message.id, type: DraftType.thread));

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
    if (_message.threadId == null)
      BlocProvider.of<MessagesBloc<T>>(context).add(event);
    else
      BlocProvider.of<ThreadsBloc<T>>(context).add(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SingleMessageBloc>(
      create: (_) => SingleMessageBloc(_message),
      lazy: false,
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
                        isThread:
                            messageState.threadId != null || _hideShowAnswers,
                        onReply: onReply,
                        onEdit: () {
                          Navigator.of(ctx).pop();
                          final smbloc = ctx.read<SingleMessageBloc>();
                          final mebloc = ctx.read<MessageEditBloc>();
                          mebloc.add(
                            EditMessage(
                                originalStr: _message.content.originalStr,
                                onMessageEditComplete: (text) {
                                  // smbloc get's closed if
                                  // listview disposes of message tile
                                  smbloc.add(UpdateContent(text));
                                  mebloc.add(CancelMessageEdit());
                                  FocusManager.instance.primaryFocus.unfocus();
                                }),
                          );
                        },
                        ctx: ctx,
                        onDelete: (ctx) => onDelete(
                            ctx,
                            RemoveMessage(
                              channelId: _message.channelId,
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
                    messageState.responsesCount != 0 &&
                    !_hideShowAnswers) {
                  onReply(context, messageState.id);
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  bottom: 12.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        ImageAvatar(
                          messageState.thumbnail,
                          width: 30,
                          height: 30,
                        ),
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
                                '${messageState.firstName} ${messageState.lastName}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff444444),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                messageState.threadId != null ||
                                        _hideShowAnswers
                                    ? DateFormatter.getVerboseDateTime(
                                        messageState.creationDate)
                                    : DateFormatter.getVerboseTime(
                                        messageState.creationDate),
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff92929C),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0),
                          MarkdownBody(
                            data: messageState.text.replaceAll('\n', '\\\n'),
                          ),
                          // Parser(messageState.content,
                          // messageState.charCount)
                          // .render(context),
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
                                  !_hideShowAnswers)
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
                ),
              ),
            );
          else
            return CircularProgressIndicator();
        },
      ),
    );
  }
}
