import 'dart:isolate';
import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/image_path.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/message/message_modal_sheet.dart';
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
  final bool isPinned;

  MessageTile({
    required this.message,
    required this.channel,
    required this.upBubbleSide,
    required this.downBubbleSide,
    this.hideShowReplies = false,
    this.shouldShowSender = true,
    this.hideReaction = false,
    this.isThread = false,
    this.isPinned = false,
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
  Widget build(BuildContext context) {
    final double _sizeOfReplyBox = _message.text.length.toDouble() < 15
        ? 80 - _message.text.length.toDouble() * 5.5
        : 5;
    final messageState = Get.find<ChannelMessagesCubit>().state;

    final bool _isDarkTheme = Get.isDarkMode ? true : false;

    if (messageState is MessagesLoadSuccess) {
      bool _isMyMessage = _message.userId == Globals.instance.userId;

      final TextStyle _parentStyle = _isDarkTheme
          ? _isMyMessage
              ? (Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w400))
              : (Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w400))
          : _isMyMessage
              ? Theme.of(context).textTheme.bodyText1!
              : (Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w400));

      return InkWell(
        onLongPress: () {
          if (_message.subtype != MessageSubtype.deleted &&
              _message.delivery == Delivery.delivered)
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
                  onPinMessage: () async {
                    Get.find<PinnedMessageCubit>()
                        .pinMessage(message: _message);
                    Navigator.of(context).pop();
                  },
                  onUnpinMessage: () async {
                    final bool result = await Get.find<PinnedMessageCubit>()
                        .unpinMessage(message: _message);
                    Navigator.of(context).pop();
                    if (!result)
                      Utilities.showSimpleSnackBar(
                          context: context,
                          message:
                              AppLocalizations.of(context)!.somethingWentWrong);
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
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 1),
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
                child: (!_isMyMessage &&
                        _shouldShowSender &&
                        widget.downBubbleSide)
                    ? ImageWidget(
                        imageType: ImageType.common,
                        imageUrl: _message.picture ?? '',
                        name: _message.sender,
                        size: 28)
                    : SizedBox(width: 28.0, height: 28.0),
              ),
              _isMyMessage && !widget.isPinned
                  ? SizedBox(width: Dim.widthPercent(8))
                  : SizedBox(width: 6),
              _buildMessageContent(_isMyMessage, _sizeOfReplyBox, _parentStyle),
              if (!_isMyMessage)
                SizedBox(
                  width: Dim.widthPercent(10),
                )
            ],
          ),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  _buildMessageContent(
          bool _isMyMessage, double _sizeOfReplyBox, TextStyle _parentStyle) =>
      Flexible(
        //  flex: widget.isPinned ? 0 : 1,
        child: Column(
          crossAxisAlignment:
              _isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: _isMyMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.isPinned && _isMyMessage
                    ? Padding(
                        padding: _message.reactions.isEmpty
                            ? const EdgeInsets.only(bottom: 15.0, right: 6)
                            : const EdgeInsets.only(bottom: 22.0, right: 6),
                        child: ImageWidget(
                            imageType: ImageType.common,
                            imageUrl: _message.picture ?? '',
                            name: _message.sender,
                            size: 28),
                      )
                    : SizedBox.shrink(),
                Flexible(
                    child: _buildMessageTextAndTime(
                        _isMyMessage, _sizeOfReplyBox, _parentStyle)),
                Container(
                  margin: const EdgeInsets.only(left: 3.0, right: 6.0),
                  child: _buildMessageSentStatus(_isMyMessage),
                )
              ],
            ),
            _buildReactions(_isMyMessage)
          ],
        ),
      );

  _buildMessageTextAndTime(
      bool _isMyMessage, double _sizeOfReplyBox, TextStyle _parentStyle) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
            color: Get.isDarkMode
                ? _isMyMessage
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.secondaryContainer
                : _isMyMessage
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).iconTheme.color,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.isPinned
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Text(
                        '${_message.sender}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: HSLColor.fromAHSL(
                                  1, _message.username.hashCode % 360, 0.9, 0.7)
                              .toColor(),
                        ),
                      ),
                    )
                  : (!widget.channel.isDirect &&
                          !_isMyMessage &&
                          widget.upBubbleSide)
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
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
                        )
                      : SizedBox.shrink(),
              Padding(
                padding: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: _message.subtype ==
                                            MessageSubtype.deleted
                                        ? Text(
                                            AppLocalizations.of(context)!
                                                .messageDeleted,
                                            style: _parentStyle.copyWith(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))
                                        : TwacodeRenderer(
                                                twacode:
                                                    _message.blocks.length == 0
                                                        ? [_message.text]
                                                        : _message.blocks,
                                                fileIds: _message.files,
                                                parentStyle: _parentStyle,
                                                userUniqueColor:
                                                    _message.username.hashCode %
                                                        360,
                                                isSwipe: false)
                                            .message,
                                  ),
                                  SizedBox(
                                      width: (_message.responsesCount > 0 &&
                                              !_message.inThread &&
                                              !_hideShowReplies)
                                          ? _sizeOfReplyBox
                                          : 0),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _message.pinnedInfo != null
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Image.asset(
                                              imagePinned,
                                              color: _isMyMessage
                                                  ? Theme.of(context)
                                                      .iconTheme
                                                      .color!
                                                      .withOpacity(0.7)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                              width: 12.0,
                                              height: 12.0,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    Text(
                                        _message.inThread || _hideShowReplies
                                            ? DateFormatter.getVerboseDateTime(
                                                _message.createdAt)
                                            : DateFormatter.getVerboseTime(
                                                _message.createdAt),
                                        textAlign: TextAlign.end,
                                        style: _parentStyle.copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400)),
                                  ],
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
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Text(
                            '${AppLocalizations.of(context)!.view} ${AppLocalizations.of(context)!.replyPlural(_message.responsesCount)}',
                            style: _isMyMessage && Get.isDarkMode
                                ? _isMyMessage
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)
                                    : Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)
                                : _isMyMessage
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)
                                    : Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildMessageSentStatus(bool _isMyMessage) {
    return _isMyMessage == true
        ? _message.delivery == Delivery.inProgress
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Icon(
                      CupertinoIcons.time_solid,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  )
                ],
              )
            : _message.delivery == Delivery.delivered
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.surface,
                        size: 20,
                      )
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
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: Icon(
                                CupertinoIcons.exclamationmark_circle_fill,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                      )
                    : Container()
        : Container();
  }

  _buildReactions(bool _isMyMessage) {
    if (!widget.hideReaction) {
      return Transform(
        transform: Matrix4.translationValues(_isMyMessage ? -28 : 16, -4, 0.0),
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
      );
    }
    return SizedBox.shrink();
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
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
        content: Row(
          children: [
            Icon(
              Icons.copy,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(
              width: 20,
            ),
            Text(AppLocalizations.of(context)!.messageCopiedInfo,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void onReply(Message message) {
    NavigatorService.instance.navigate(
      channelId: message.channelId,
      threadId: message.id,
      reloadThreads: false,
    );
  }
}
