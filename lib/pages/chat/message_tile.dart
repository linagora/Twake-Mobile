import 'dart:isolate';
import 'dart:ui';
import 'package:bubble/bubble.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/widgets/common/user_thumbnail.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';

import 'package:twake/widgets/common/reaction.dart';

final RegExp singleLineFeed = RegExp('(?<!\n)\n(?!\n)');

class MessageTile<T extends BaseMessagesCubit> extends StatefulWidget {
  final bool hideShowAnswers;
  final bool shouldShowSender;
  final Message message;
  final Channel channel;
  final bool upBubbleSide;
  final bool downBubbleSide;

  MessageTile({
    required this.message,
    required this.channel,
    required this.upBubbleSide,
    required this.downBubbleSide,
    this.hideShowAnswers = false,
    this.shouldShowSender = true,
    Key? key,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState<T>();
}

class _MessageTileState<T extends BaseMessagesCubit>
    extends State<MessageTile> {
  late bool _hideShowAnswers;
  late bool _shouldShowSender;
  late Message _message;
  ReceivePort _receivePort = ReceivePort();
  int progress = 0;

  // static downloadingCallback(id, status, progress) {
  // SendPort sendPort = IsolateNameServer.lookupPortByName("downloading")!;
  // sendPort.send([id, status, progress]);
  // }
  Size wdgtHieght = Size(0, 0);
  // use _wdgtKey in the Bubble
  double h = 1;

  @override
  void initState() {
    super.initState();
    _hideShowAnswers = widget.hideShowAnswers;
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
    if (oldWidget.hideShowAnswers != widget.hideShowAnswers) {
      _hideShowAnswers = widget.hideShowAnswers;
    }
    if (oldWidget.message != widget.message) {
      _message = widget.message;
    }
  }

  void onReply(Message message) {
    NavigatorService.instance
        .navigate(channelId: message.channelId, threadId: message.id);
  }

  onCopy({required context, required text}) {
    FlutterClipboard.copy(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1000),
        content: Text('Message has been copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageState = Get.find<ChannelMessagesCubit>().state;
    if (messageState is MessagesLoadSuccess) {
      bool _isMyMessage = _message.userId == Globals.instance.userId;

      return InkWell(
        onLongPress: () {
          if (_message.isDelivered || _isMyMessage == false)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              //  barrierColor: Colors.white30,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return MessageModalSheet<T>(
                  message: _message,
                  isMe: _isMyMessage,
                  onReply: onReply,
                  onEdit: () {
                    Get.find<ChannelMessagesCubit>()
                        .startEdit(message: _message);
                    Navigator.of(context).pop();
                  },
                  ctx: context,
                  onDelete: () {
                    Get.find<ChannelMessagesCubit>().delete(message: _message);
                    Navigator.pop(context);
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
          if (_message.responsesCount != 0 && !_hideShowAnswers) {
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
                  ? const EdgeInsets.only(bottom: 2.0)
                  : const EdgeInsets.only(bottom: 22.0),
              child: (!_isMyMessage && _shouldShowSender)
                  ? UserThumbnail(
                      thumbnailUrl: _message.picture ?? '',
                      userName: _message.sender,
                      size: 28.0,
                    )
                  : SizedBox(width: 28.0, height: 28.0),
            ),
            SizedBox(width: 6.0),
            Flexible(
              child: Container(
                child: Stack(
                  children: [
                    Container(
                      padding: _message.reactions.isEmpty
                          ? const EdgeInsets.only(bottom: 1.0)
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
                            //crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!widget.channel.isDirect && !_isMyMessage)
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 6, 1, 1),
                                    child: Text(
                                      '${_message.sender}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: HSLColor.fromAHSL(
                                                1,
                                                _message.username.hashCode %
                                                    360,
                                                0.9,
                                                0.3)
                                            .toColor(),
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(12.0, 5.0, 2.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        children: [
                                          TwacodeRenderer(
                                            _message.blocks,
                                            TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w400,
                                              color: _isMyMessage
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            _message.username.hashCode % 360,
                                          ).message,
                                          SizedBox(
                                            height: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _message.inThread || _hideShowAnswers
                                              ? DateFormatter
                                                  .getVerboseDateTime(
                                                  _message.createdAt,
                                                )
                                              : DateFormatter.getVerboseTime(
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
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.0),
                              /*   if (_message.responsesCount > 0 &&
                                    _message.threadId == null &&
                                    !_hideShowAnswers)
                                  Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    color: _isMyMessage
                                        ? Colors.white.withOpacity(0.19)
                                        : Color(0xFF979797).withOpacity(0.19),
                                  ),*/
                              if (_message.responsesCount > 0 &&
                                  !_message.inThread &&
                                  !_hideShowAnswers)
                                Container(
                                  padding:
                                      EdgeInsets.only(top: 15.0, bottom: 15.0),
                                  // alignment: Alignment.bottomCenter,
                                  child: Text(
                                    'View ${_message.responsesCount} replies',
                                    style: TextStyle(
                                      color: _isMyMessage
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
            _message.isDelivered && _isMyMessage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF004DFF),
                        size: 20,
                      ),
                      _message.reactions.isEmpty
                          ? SizedBox(height: 5.0)
                          : SizedBox(height: 24.0)
                    ],
                  )
                : Container(),
            _message.isDelivered && _isMyMessage
                ? SizedBox(width: 8.0)
                : SizedBox(width: 12.0)
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
