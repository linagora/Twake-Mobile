import 'package:flutter/material.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/message/message.dart';

class MessageModalSheet<T extends BaseMessagesCubit> extends StatefulWidget {
  final Message message;
  final void Function(BuildContext, String?, {bool? autofocus})? onReply;
  final void Function()? onDelete;
  final Function? onEdit;
  final Function? onCopy;
  final BuildContext? ctx;
  final bool isMe;

  const MessageModalSheet({
    required this.message,
    this.onReply,
    this.onDelete,
    this.onEdit,
    this.onCopy,
    this.ctx,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  @override
  _MessageModalSheetState createState() => _MessageModalSheetState<T>();
}

class _MessageModalSheetState<T extends BaseMessagesCubit>
    extends State<MessageModalSheet> {
  bool _emojiVisible = false;

  onEmojiSelected(String emojiCode) {
    Get.find<T>().react(message: widget.message, reaction: emojiCode);
    FocusManager.instance.primaryFocus!.unfocus();
  }

  void showEmojiBoard() async {
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }

  Widget buildEmojiBoard() {
    return EmojiKeyboard(
      onEmojiSelected: (emoji) {
        onEmojiSelected(emoji.text);
        Navigator.of(context).pop();
      },
      height: MediaQuery.of(context).size.height * 0.35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _emojiVisible
        ? buildEmojiBoard()
        : SafeArea(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiLine(
                      onEmojiSelected: onEmojiSelected,
                      showEmojiBoard: showEmojiBoard),
                  Divider(
                    thickness: 1.0,
                    height: 1.0,
                    color: Color(0xffEEEEEE),
                  ),
                  if (widget.isMe)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(Icons.edit),
                      title: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff444444),
                        ),
                      ),
                      onTap: widget.onEdit as void Function()?,
                    ),
                  if (widget.message.threadId != null)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(Icons.reply_sharp),
                      title: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff444444),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onReply!(context, widget.message.id,
                            autofocus: true);
                      },
                    ),
                  if (widget.message.threadId != null)
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Color(0xffEEEEEE),
                    ),
                  if (widget.isMe && widget.message.responsesCount == 0)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(Icons.delete, color: Color(0xffFF5154)),
                      title: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffFF5154),
                        ),
                      ),
                      onTap: () {
                        widget.onDelete!();
                      },
                    ),
                  if (widget.isMe && widget.message.responsesCount == 0)
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Color(0xffEEEEEE),
                    ),
                  widget.message.content.originalStr?.isEmpty ?? true
                      ? Container()
                      : ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          leading: Icon(Icons.copy),
                          title: Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff444444),
                            ),
                          ),
                          onTap: widget.onCopy as void Function()?,
                        ),
                ],
              ),
            ),
          );
  }
}

class EmojiLine extends StatelessWidget {
  final Function? onEmojiSelected;
  final Function? showEmojiBoard;

  EmojiLine({this.onEmojiSelected, this.showEmojiBoard});

  static const EMOJISET = [
    '😅',
    '😂',
    '😇',
    '👍',
    '👌',
    '👋',
    '🙏',
  ];

  @override
  Widget build(BuildContext context) {
    final fontSize = 27.0;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Dim.heightMultiplier,
        horizontal: 16.0, //Dim.wm2,
      ),
      constraints: BoxConstraints(maxHeight: Dim.hm7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...EMOJISET.map((e) => InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onEmojiSelected!(e);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    e,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              )),
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.tag_faces),
            onPressed: showEmojiBoard as void Function()?,
            iconSize: fontSize + 3,
          ),
        ],
      ),
    );
  }
}
