import 'dart:io';
import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:mime/mime.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/message_edit_bloc/message_edit_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/single_message_bloc/single_message_bloc.dart';
import 'package:twake/blocs/threads_bloc/threads_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/feed/user_thumbnail.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';
import 'package:twake/utils/notify.dart';

final RegExp singleLineFeed = RegExp('(?<!\n)\n(?!\n)');

class MessageTile<T extends BaseChannelBloc> extends StatefulWidget {
  final bool hideShowAnswers;
  final bool shouldShowSender;
  final Message message;

  MessageTile({
    this.message,
    this.hideShowAnswers = false,
    this.shouldShowSender = true,
    Key key,
  }) : super(key: key);

  @override
  _MessageTileState<T> createState() => _MessageTileState<T>();
}

class _MessageTileState<T extends BaseChannelBloc>
    extends State<MessageTile<T>> {
  bool _hideShowAnswers;
  bool _shouldShowSender;
  bool progressVisible = false;
  Message _message;
  double _progress = 0;
  CancelToken cancelToken = CancelToken();
  // String fileType;
  Size wdgtHieght;
  final GlobalKey _wdgtKey = GlobalKey();
  double h = 1;
  @override
  void initState() {
    super.initState();
    _hideShowAnswers = widget.hideShowAnswers;
    _shouldShowSender = widget.shouldShowSender;

    _message = widget.message;
    WidgetsBinding.instance
        .addPersistentFrameCallback((_) => getSizeAndPosition());

    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  void didUpdateWidget(covariant MessageTile<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldShowSender != widget.shouldShowSender) {
      _shouldShowSender = widget.shouldShowSender;
    }
    if (oldWidget.hideShowAnswers != widget.hideShowAnswers) {
      _hideShowAnswers = widget.hideShowAnswers;
    }
    if (oldWidget.message != widget.message) {
      _message = widget.message;
    }
  }

  Future<void> onNotificationClick(String payloadPath) async {
    //print('payloadPath $payloadPath');
    if (Platform.isAndroid) {
      OpenFile.open(payloadPath);
      // fileType = lookupMimeType(payloadPath);
    }
    if (Platform.isIOS) {
      OpenFile.open("$payloadPath");
      //  fileType = lookupMimeType(payloadPath);
    }
  }

  getSizeAndPosition() async {
    // Future.delayed(Duration(seconds: 1));
    RenderBox _rdrBox = _wdgtKey.currentContext.findRenderObject();
    wdgtHieght = _rdrBox.size;
    setState(() {
      h = _rdrBox.size.height;
    });
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total);
        print(_progress);
        progressVisible = true;
      });
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
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
        builder: (context, messageState) {
          if (messageState is MessageReady) {
            getSizeAndPosition();
            bool _isMyMessage = messageState.userId == ProfileBloc.userId;
            return InkWell(
              onLongPress: () {
                BlocProvider.of<MessageEditBloc>(context)
                    .add(CancelMessageEdit());
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return MessageModalSheet(
                      originalStr: _message.content.originalStr,
                      userId: messageState.userId,
                      messageId: messageState.id,
                      responsesCount: messageState.responsesCount,
                      isThread:
                          messageState.threadId != null || _hideShowAnswers,
                      onReply: onReply,
                      onEdit: () {
                        Navigator.of(context).pop();
                        // ignore: close_sinks
                        final smbloc = context.read<SingleMessageBloc>();
                        // ignore: close_sinks
                        final mebloc = context.read<MessageEditBloc>();
                        mebloc.add(
                          EditMessage(
                            originalStr: _message.content.originalStr ?? '',
                            onMessageEditComplete: (text, context) async {
                              // smbloc gets closed if
                              // listview disposes of message tile
                              smbloc.add(
                                UpdateContent(
                                  content: await BlocProvider.of<MentionsCubit>(
                                    context,
                                  ).completeMentions(text),
                                  workspaceId:
                                      T == DirectsBloc ? 'direct' : null,
                                ),
                              );
                              mebloc.add(CancelMessageEdit());
                              FocusManager.instance.primaryFocus.unfocus();
                            },
                          ),
                        );
                      },
                      ctx: context,
                      onDelete: (context) {
                        onDelete(
                          context,
                          RemoveMessage(
                            channelId: _message.channelId,
                            messageId: messageState.id,
                            threadId: messageState.threadId,
                          ),
                        );
                      },
                      onCopy: () {
                        onCopy(context: context, text: messageState.text);
                      },
                    );
                  },
                );
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
                padding: const EdgeInsets.only(
                  left: 6.0,
                  right: 12.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: _isMyMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: (!_isMyMessage && _shouldShowSender)
                          ? UserThumbnail(
                              thumbnailUrl: messageState.thumbnail,
                              userName: (messageState.sender != null ||
                                      messageState.sender.isEmpty)
                                  ? ''
                                  : messageState.sender,
                              size: 24.0,
                            )
                          : SizedBox(width: 24.0, height: 24.0),
                    ),
                    SizedBox(width: 6.0),
                    Flexible(
                      child: Bubble(
                        color: _isMyMessage
                            ? Color(0xff004dff)
                            : Color(0xfff6f6f6),
                        elevation: 0,
                        padding: BubbleEdges.fromLTRB(13.0, 12.0, 12.0, 8.0),
                        radius: Radius.circular(18.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_isMyMessage)
                                    Text(
                                      messageState.sender ?? '',
                                      style: TextStyle(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff444444),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  SizedBox(height: _isMyMessage ? 0.0 : 4.0),
                                  Stack(children: <Widget>[
                                    Container(
                                      key: _wdgtKey,
                                      child: TwacodeRenderer(
                                        //  progress: _progress,
                                        onReceiveProgress: _onReceiveProgress,
                                        twacode: messageState.content,
                                        parentStyle: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w400,
                                          color: _isMyMessage
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ).message,
                                    ),
                                    progressVisible
                                        ? Container(
                                            margin: EdgeInsets.all(16),
                                            padding: EdgeInsets.only(top: h),
                                            height: 40,
                                            width: 40,
                                            color: _isMyMessage
                                                ? Color(0xff004dff)
                                                : Color(0xfff6f6f6),
                                          )
                                        : Container(
                                            margin: EdgeInsets.all(20),
                                            padding: EdgeInsets.all(20),
                                            height: 40,
                                            width: 40,
                                            color: _isMyMessage
                                                ? Colors.green
                                                : Colors.green,
                                          ),
                                    progressVisible
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                //height: h - 10,
                                                height: 20,
                                              ),
                                              Container(
                                                  margin: EdgeInsets.all(4),
                                                  padding: EdgeInsets.all(3),
                                                  child: buildProgress(
                                                      _isMyMessage)),
                                            ],
                                          )
                                        : SizedBox.shrink(),
                                  ]),

                                  // Normally we use SizedBox here,
                                  // but it will cut the bottom of emojis
                                  // in last line of the messsage.
                                  Container(
                                    color: Colors.transparent,
                                    width: 10.0,
                                    height: 5.0,
                                  ),
                                  Wrap(
                                    runSpacing: Dim.heightMultiplier,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    textDirection: TextDirection.ltr,
                                    children: [
                                      ...messageState.reactions.map((r) {
                                        return Reaction(
                                          r['name'],
                                          r['count'],
                                          T == DirectsBloc ? 'direct' : null,
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
                            SizedBox(width: 10.0),
                            Text('${h}'),
                            SizedBox(width: h / 4),
                            Text(
                              messageState.threadId != null || _hideShowAnswers
                                  ? DateFormatter.getVerboseDateTime(
                                      messageState.creationDate)
                                  : DateFormatter.getVerboseTime(
                                      messageState.creationDate),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: _isMyMessage
                                    ? Color(0xffffffff).withOpacity(0.58)
                                    : Color(0xff8e8e93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget buildProgress(bool _isMyMessage) {
    if (_progress == 1) {
      return //fileType != "mp3"
          SizedBox(
        child: CircleAvatar(
          child: Icon(
            Icons.insert_drive_file_rounded,
            color: _isMyMessage ? Color(0xfff6f6f6) : Color(0xff004dff),
          ),
          backgroundColor: _isMyMessage
              ? Color(0xfff6f6f6).withOpacity(0.12)
              : Color(0xff004dff).withOpacity(0.08),
        ),
        width: 40,
        height: 40,
      );
    } else {
      return InkWell(
          child: SizedBox(
            child: Stack(
              children: <Widget>[
                /*        CircleAvatar(
                      child: Icon(
                        Icons.cancel_outlined,
                        color: _isMyMessage
                            ? Color(0xfff6f6f6)
                            : Color(0xff004dffC),
                      ),
                      backgroundColor: _isMyMessage
                          ? Color(0xff004dff).withOpacity(0.08)
                          : Color(0xfff6f6f6).withOpacity(0.12)),  */
                CircularProgressIndicator(
                  value: _progress,
                  valueColor: AlwaysStoppedAnimation(
                    _isMyMessage ? Color(0xfff6f6f6) : Color(0xff004dff),
                  ),
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
            width: 40,
            height: 40,
          ),
          onTap: () {
            //    if (_progress != 0) {
            //     cancelToken.cancel();
            //      progressVisible = false;
            //  }
          });
    }
  }
}
