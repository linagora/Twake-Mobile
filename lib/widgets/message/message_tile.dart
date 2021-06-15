import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';

final RegExp singleLineFeed = RegExp('(?<!\n)\n(?!\n)');

class MessageTile<T extends BaseMessagesCubit> extends StatefulWidget {
  final bool hideShowAnswers;
  final Message message;

  MessageTile({
    required this.message,
    this.hideShowAnswers: false,
    Key? key,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState<T>();
}

class _MessageTileState<T extends BaseMessagesCubit>
    extends State<MessageTile> {
  late bool _hideShowAnswers;
  late Message _message;

  @override
  void initState() {
    super.initState();
    _hideShowAnswers = widget.hideShowAnswers;
    _message = widget.message;
  }

  void onReply(context, String? messageId, {bool autofocus: false}) {
    /*  TODO implement ThreadPage
     
    BlocProvider.of<MessagesBloc<T>>(context).add(SelectMessage(messageId));
    BlocProvider.of<DraftBloc>(context)
        .add(LoadDraft(id: _message!.id, type: DraftType.thread));  */

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreadPage(
          autofocus: autofocus,
        ),
      ),
    );
  }

  onCopy({required context, required text}) {
    FlutterClipboard.copy(text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1300),
        content: Text('Message has been copied to clipboard'),
      ),
    );
  }

  void onDelete(Message message) {
    Get.find<ThreadMessagesCubit>().delete(message: message);
  }

  @override
  Widget build(BuildContext context) {
    final messageState = Get.find<ThreadMessagesCubit>().state;
    if (messageState is MessagesLoadSuccess) {
      bool _isMyMessage = _message.userId == Globals.instance.userId;

      return InkWell(
        onLongPress: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) {
                return MessageModalSheet<T>(
                  message: _message,
                  isMe: _isMyMessage,
                  //  onReply: onReply,
                  onEdit: () {
                    /*
                          Navigator.of(ctx).pop();
                          // ignore: close_sinks
                          final smbloc = ctx.read<SingleMessageBloc>();
                          // ignore: close_sinks
                          final mebloc = ctx.read<MessageEditBloc>();
                          mebloc.add(
                            EditMessage(
                              originalStr: _message!.content!.originalStr ?? '',
                              onMessageEditComplete: (text, context) {
                                // smbloc gets closed if
                                // listview disposes of message tile
                                smbloc.add(
                                  UpdateContent(
                                    content: text,
                                    workspaceId:
                                        T == DirectsBloc ? 'direct' : null,
                                  ),
                                );
                                mebloc.add(CancelMessageEdit());
                                FocusManager.instance.primaryFocus!.unfocus();
                              },
                            ),
                          );*/
                  },
                  ctx: context,
                  onDelete: (context) {
                    /*
                        onDelete(
                          context,
                          RemoveMessage(
                            channelId: _message!.channelId,
                            messageId: messageState.id,
                            threadId: messageState.threadId,
                          ),
                        );*/
                    Get.find<ChannelMessagesCubit>().delete(message: _message);
                  },
                  onCopy: () {
                    onCopy(
                        context: context, text: _message.content.originalStr);
                  },
                );
              });
        },
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
          if (_message.threadId == null &&
              _message.responsesCount != 0 &&
              !_hideShowAnswers) {
            onReply(context, _message.id);
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
            children: [
              Column(
                children: [
                  ImageAvatar(
                    _message.thumbnail,
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _message.sender,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff444444),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _message.threadId != null || _hideShowAnswers
                              ? DateFormatter.getVerboseDateTime(
                                  _message.creationDate)
                              : DateFormatter.getVerboseTime(
                                  _message.creationDate),
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff92929C),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    TwacodeRenderer(
                      twacode: _message.content.prepared,
                      parentStyle: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ).message,
                    // Normally we use SizedBox here,
                    // but it will cut the bottom of emojis
                    // in last line of the messsage.
                    Container(
                      color: Colors.transparent,
                      height: 5.0,
                    ),
                    Wrap(
                      runSpacing: Dim.heightMultiplier,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      textDirection: TextDirection.ltr,
                      children: [
                        ..._message.reactions.map((r) {
                          return Reaction<T>(
                            message: _message,
                            reaction: r,
                          );
                        }),
                        if (_message.responsesCount > 0 &&
                            _message.threadId == null &&
                            !_hideShowAnswers)
                          Text(
                            'See all answers (${_message.responsesCount})',
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
    } else {
      return CircularProgressIndicator();
    }
  }
}
