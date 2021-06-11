import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class MessageModalSheet extends StatefulWidget {
  final String? userId;
  final String? messageId;
  final String? originalStr;
  final int? responsesCount;
  final void Function(BuildContext, String?, {bool? autofocus})? onReply;
  final void Function(BuildContext)? onDelete;
  final Function? onEdit;
  final Function? onCopy;
  final bool isThread;
  final BuildContext? ctx;
  final bool isMe;

  const MessageModalSheet({
    this.userId,
    this.messageId,
    this.responsesCount,
    this.isThread: false,
    this.onReply,
    this.onDelete,
    this.onEdit,
    this.onCopy,
    this.ctx,
    this.originalStr,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  @override
  _MessageModalSheetState createState() => _MessageModalSheetState();
}

class _MessageModalSheetState extends State<MessageModalSheet> {
  bool _emojiVisible = false;

  onEmojiSelected(String emojiCode) {
    //BlocProvider.of<SingleMessageBloc>(widget.ctx!)
    //    .add(UpdateReaction(emojiCode: emojiCode));
    //  FocusManager.instance.primaryFocus!.unfocus();
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
    //  final bool isMe = BlocProvider.of<ProfileBloc>(context).isMe(widget.userId);

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
                  if (!widget.isThread)
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
                        widget.onReply!(context, widget.messageId,
                            autofocus: true);
                      },
                    ),
                  if (!widget.isThread)
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Color(0xffEEEEEE),
                    ),
                  if (widget.isMe && widget.responsesCount == 0)
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
                        widget.onDelete!(context);
                      },
                    ),
                  if (widget.isMe && widget.responsesCount == 0)
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Color(0xffEEEEEE),
                    ),
                  widget.originalStr!.isEmpty
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
