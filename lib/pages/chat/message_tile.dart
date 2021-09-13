import 'dart:isolate';
import 'dart:ui';
import 'package:bubble/bubble.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/message/resend_modal_sheet.dart';

class MessageTile<T extends BaseMessagesCubit> extends StatefulWidget {
  final bool hideShowReplies;
  final bool shouldShowSender;
  final Message message;
  final Channel channel;
  final bool hideReaction;
  final bool upBubbleSide;
  final bool downBubbleSide;
  final bool isThread;

  MessageTile({
    required this.message,
    required this.channel,
    required this.upBubbleSide,
    required this.downBubbleSide,
    this.hideShowReplies = false,
    this.shouldShowSender = true,
    this.hideReaction = false,
    this.isThread = false,
    Key? key,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState<T>();
}

class _MessageTileState<T extends BaseMessagesCubit>
    extends State<MessageTile> {
  late bool _hideShowReplies;
  late bool _shouldShowSender;
  late Message _message;
  ReceivePort _receivePort = ReceivePort();
  int progress = 0;

  @override
  void initState() {
    super.initState();
    _hideShowReplies = widget.hideShowReplies;
    _shouldShowSender = widget.shouldShowSender;
    _message = widget.message;

    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");
    // FlutterDownloader.registerCallback(downloadingCallback);
  }

  @override
  void didUpdateWidget(covariant MessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldShowSender != widget.shouldShowSender) {
      _shouldShowSender = widget.shouldShowSender;
    }
    if (oldWidget.hideShowReplies != widget.hideShowReplies) {
      _hideShowReplies = widget.hideShowReplies;
    }
    if (oldWidget.message != widget.message) {
      _message = widget.message;
    }
  }

  void onReply(Message message) {
    NavigatorService.instance.navigate(
      channelId: message.channelId,
      threadId: message.id,
      reloadThreads: false,
    );
  }

  onCopy({required context, required text}) {
    FlutterClipboard.copy(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.fromLTRB(
          15.0,
          5.0,
          15.0,
          65.0,
          //  Dim.heightPercent(8),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
        content: Row(
          children: [
            Icon(Icons.copy, color: Colors.white),
            SizedBox(
              width: 20,
            ),
            Text('Message has been copied to clipboard'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sizeOfReplyBox = _message.text.length.toDouble() < 15
        ? 80 - _message.text.length.toDouble() * 5.5
        : 5;
    final messageState = Get.find<ChannelMessagesCubit>().state;
    if (messageState is MessagesLoadSuccess) {
      bool _isMyMessage = _message.userId == Globals.instance.userId;
      return InkWell(
        onLongPress: () {
          if (_message.delivery == Delivery.delivered || _isMyMessage == false)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              //  barrierColor: Colors.white30,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return MessageModalSheet<T>(
                  message: _message,
                  isMe: _isMyMessage,
                  isThread: widget.isThread,
                  onReply: onReply,
                  onEdit: () {
                    widget.isThread
                        ? Get.find<ThreadMessagesCubit>()
                            .startEdit(message: _message)
                        : Get.find<ChannelMessagesCubit>()
                            .startEdit(message: _message);
                    Navigator.of(context).pop();
                  },
                  ctx: context,
                  onDelete: () {
                    widget.isThread
                        ? Get.find<ThreadMessagesCubit>()
                            .delete(message: _message)
                        : Get.find<ChannelMessagesCubit>()
                            .delete(message: _message);
                    Navigator.of(context).pop();
                  },
                  onCopy: () {
                    onCopy(context: context, text: _message.text);
                    Navigator.of(context).pop();
                  },
                );
              },
            );
        },
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
          if (_message.responsesCount != 0 && !_hideShowReplies) {
            onReply(_message);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
              _isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            SizedBox(width: 6.0),
            Padding(
              padding: _message.reactions.isEmpty
                  ? const EdgeInsets.only(bottom: 15.0)
                  : const EdgeInsets.only(bottom: 22.0),
              child:
                  (!_isMyMessage && _shouldShowSender && widget.downBubbleSide)
                      ? ImageWidget(
                          imageType: ImageType.common,
                          imageUrl: _message.picture ?? '',
                          name: _message.sender,
                          size: 28,
                        )
                      : SizedBox(width: 28.0, height: 28.0),
            ),
            _isMyMessage
                ? SizedBox(
                    width: Dim.widthPercent(8),
                  )
                : SizedBox(
                    width: 6,
                  ),
            Flexible(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                      padding: _message.reactions.isEmpty
                          ? widget.downBubbleSide
                              ? const EdgeInsets.only(bottom: 12.0, top: 3)
                              : const EdgeInsets.only(bottom: 1.0)
                          : const EdgeInsets.only(bottom: 22.0),
                      color: Colors.white,
                      child: ClipRRect(
                        borderRadius: _isMyMessage
                            ? (widget.upBubbleSide && widget.downBubbleSide
                                ? (BorderRadius.circular(18))
                                : (widget.upBubbleSide || widget.downBubbleSide
                                    ? (widget.upBubbleSide == true
                                        ? (BorderRadius.only(
                                            bottomRight: Radius.circular(4),
                                            topRight: Radius.circular(18),
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18)))
                                        : (BorderRadius.only(
                                            topRight: Radius.circular(4),
                                            bottomRight: Radius.circular(18),
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18))))
                                    : (BorderRadius.only(
                                        bottomRight: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                        topLeft: Radius.circular(18),
                                        bottomLeft: Radius.circular(18)))))
                            : (widget.upBubbleSide && widget.downBubbleSide
                                ? (BorderRadius.circular(18))
                                : (widget.upBubbleSide || widget.downBubbleSide
                                    ? (widget.upBubbleSide == true
                                        ? (BorderRadius.only(
                                            bottomLeft: Radius.circular(4),
                                            topLeft: Radius.circular(18),
                                            topRight: Radius.circular(18),
                                            bottomRight: Radius.circular(18)))
                                        : (BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            bottomLeft: Radius.circular(18),
                                            topRight: Radius.circular(18),
                                            bottomRight: Radius.circular(18))))
                                    : (BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(18),
                                        bottomRight: Radius.circular(18))))),
                        child: Bubble(
                          style: BubbleStyle(
                            nip: BubbleNip.no,
                            radius: Radius.circular(0),
                            elevation: 0,
                            color: _isMyMessage
                                ? Color(0xff007AFF)
                                : Color(0xFFF0F1F5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!widget.channel.isDirect &&
                                  !_isMyMessage &&
                                  widget.upBubbleSide)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  child: Text(
                                    '${_message.sender}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: HSLColor.fromAHSL(
                                              1,
                                              _message.username.hashCode % 360,
                                              0.9,
                                              0.3)
                                          .toColor(),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(12.0, 5.0, 6.0, 0.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: TwacodeRenderer(
                                                      twacode: _message.blocks,
                                                      parentStyle: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: _isMyMessage
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                      userUniqueColor: _message
                                                              .username
                                                              .hashCode %
                                                          360,
                                                      isSwipe: false,
                                                    ).message,
                                                  ),
                                                  SizedBox(
                                                      width: (_message.responsesCount >
                                                                  0 &&
                                                              !_message
                                                                  .inThread &&
                                                              !_hideShowReplies)
                                                          ? sizeOfReplyBox
                                                          : 0),
                                                ],
                                              ),
                                              Text(
                                                _message.inThread ||
                                                        _hideShowReplies
                                                    ? DateFormatter
                                                        .getVerboseDateTime(
                                                        _message.createdAt,
                                                      )
                                                    : DateFormatter
                                                        .getVerboseTime(
                                                        _message.createdAt,
                                                      ),
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic,
                                                  color: _isMyMessage
                                                      ? Color(0xffffffff)
                                                          .withOpacity(0.58)
                                                      : Color(0xFF8E8E93),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_message.responsesCount > 0 &&
                                        !_message.inThread &&
                                        !_hideShowReplies)
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 15.0, bottom: 15.0),
                                        child: Text(
                                          _message.responsesCount > 1
                                              ? 'View ${_message.responsesCount} replies'
                                              : 'View ${_message.responsesCount} reply',
                                          style: TextStyle(
                                            color: _isMyMessage
                                                ? Colors.white
                                                : Color(0xFF004DFF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!widget.hideReaction)
                      Positioned(
                        left: 17.0,
                        bottom: -1.0,
                        child: Wrap(
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
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 3.0),
            _isMyMessage == true
                ? _message.delivery == Delivery.inProgress
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white,
                            child: Icon(
                              CupertinoIcons.time_solid,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ),
                          if (widget.downBubbleSide)
                            _message.reactions.isEmpty
                                ? SizedBox(height: 10.0)
                                : SizedBox(height: 18.0),
                          if (_message.reactions.isNotEmpty &&
                              !widget.downBubbleSide)
                            SizedBox(height: 18.0)
                        ],
                      )
                    : _message.delivery == Delivery.delivered
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF004DFF),
                                size: 20,
                              ),
                              if (widget.downBubbleSide)
                                _message.reactions.isEmpty
                                    ? SizedBox(height: 10.0)
                                    : SizedBox(height: 18.0),
                              if (_message.reactions.isNotEmpty &&
                                  !widget.downBubbleSide)
                                SizedBox(height: 18.0)
                            ],
                          )
                        : _message.delivery == Delivery.failed
                            ? GestureDetector(
                                onTap: () async {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) {
                                      return ResendModalSheet(
                                        message: _message,
                                        isThread: widget.isThread,
                                      );
                                    },
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        CupertinoIcons
                                            .exclamationmark_circle_fill,
                                        color: Colors.red[400],
                                        size: 20,
                                      ),
                                    ),
                                    if (widget.downBubbleSide)
                                      _message.reactions.isEmpty
                                          ? SizedBox(height: 10.0)
                                          : SizedBox(height: 18.0),
                                    if (_message.reactions.isNotEmpty &&
                                        !widget.downBubbleSide)
                                      SizedBox(height: 18.0)
                                  ],
                                ),
                              )
                            : Container()
                : Container(),
            SizedBox(width: 6.0),
            if (!_isMyMessage)
              SizedBox(
                width: Dim.widthPercent(10),
              )
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
