import 'dart:isolate';
import 'dart:ui';
import 'package:bubble/bubble.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/feed/user_thumbnail.dart';
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

  MessageTile({
    required this.message,
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
  double _width = 0.0;
  double _height = 0.0;

  // static downloadingCallback(id, status, progress) {
  // SendPort sendPort = IsolateNameServer.lookupPortByName("downloading")!;
  // sendPort.send([id, status, progress]);
  // }

  @override
  void initState() {
    super.initState();
    _hideShowAnswers = widget.hideShowAnswers;
    _shouldShowSender = widget.shouldShowSender;
    _message = widget.message;

    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");
    // FlutterDownloader.registerCallback(downloadingCallback);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        // setState(() {
        _width = context.size?.width ?? 0.0;
        _height = context.size?.height ?? 0.0;
        print('Width: $_width');
        print('Height: $_height');
        // });
      }
    });
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return MessageModalSheet<T>(
                message: _message,
                isMe: _isMyMessage,
                onReply: onReply,
                onEdit: () {
                  Get.find<ChannelMessagesCubit>().startEdit(message: _message);
                  Navigator.of(context).pop();
                },
                ctx: context,
                onDelete: () {
                  Get.find<ChannelMessagesCubit>().delete(message: _message);
                  Navigator.pop(context);
                },
                onCopy: () {
                  onCopy(context: context, text: _message.content.originalStr);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
          if (_message.threadId == null &&
              _message.responsesCount != 0 &&
              !_hideShowAnswers) {
            onReply(_message);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: _isMyMessage
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            SizedBox(width: 6.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: (!_isMyMessage && _shouldShowSender)
                  ? UserThumbnail(
                      thumbnailUrl: _message.thumbnail,
                      userName: _message.sender,
                      size: 24.0,
                    )
                  : SizedBox(width: 24.0, height: 24.0),
            ),
            SizedBox(width: 6.0),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  color: Colors.white,
                  child: Bubble(
                    style: BubbleStyle(
                      nip: _isMyMessage
                          ? BubbleNip.rightBottom
                          : BubbleNip.leftBottom,
                      nipWidth: 0.01,
                      nipHeight: 20,
                      nipRadius: 0.0,
                      radius: Radius.circular(18.0),
                      padding: BubbleEdges.fromLTRB(13.0, 12.0, 12.0, 10.0),
                      elevation: 0,
                      color: _isMyMessage
                          ? Color(0xff004dff)
                          : Color(0xfff6f6f6),
                    ),
                    // borderUp: false,
                    // borderWidth: 2.0,
                    // borderColor: Colors.black,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TwacodeRenderer(
                          twacode: _message.content.prepared,
                          parentStyle: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color:
                                _isMyMessage ? Colors.white : Colors.black,
                          ),
                        ).message,
                        SizedBox(width: 10.0),
                        Text(
                          _message.threadId != null || _hideShowAnswers
                              ? DateFormatter.getVerboseDateTime(
                                  _message.creationDate)
                              : DateFormatter.getVerboseTime(
                                  _message.creationDate),
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

                Positioned(
                  left: 10.0,
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
                      if (_message.responsesCount > 0 &&
                          _message.threadId == null &&
                          !_hideShowAnswers)
                        Text(
                          'See all answers (${_message.responsesCount})',
                          style: StylesConfig.miniPurple,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 26.0),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
