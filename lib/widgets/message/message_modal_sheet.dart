import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/message/message.dart';

class MessageModalSheet<T extends BaseMessagesCubit> extends StatefulWidget {
  final Message message;
  final void Function(Message)? onReply;
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
    Future.delayed(
      Duration(milliseconds: 50),
      FocusManager.instance.primaryFocus?.unfocus,
    );
  }

  void toggleEmojiBoard() async {
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }

  Widget buildEmojiBoard() {
    return Container(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (cat, emoji) {
          toggleEmojiBoard();
          onEmojiSelected(emoji.emoji);
        },
        config: Config(
          columns: 7,
          emojiSizeMax: 32.0,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: Color(0xFFF2F2F2),
          indicatorColor: Colors.blue,
          iconColor: Colors.grey,
          iconColorSelected: Colors.blue,
          progressIndicatorColor: Colors.blue,
          showRecentsTab: true,
          recentsLimit: 28,
          noRecentsText: "No Recents",
          noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _emojiVisible
        ? buildEmojiBoard()
        : SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child: EmojiLine(
                      onEmojiSelected: onEmojiSelected,
                      showEmojiBoard: toggleEmojiBoard,
                    ),
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isMe &&
                                widget.message.responsesCount == 0)
                              GestureDetector(
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.delete,
                                            color: Color(0xffFF5154)),
                                        Text(
                                          'delete',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFFF3347),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  widget.onDelete!();
                                },
                              ),
                            SizedBox(
                              width: 30,
                            ),
                            widget.message.content.originalStr?.isEmpty ?? true
                                ? Container()
                                : GestureDetector(
                                    child: Container(
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.copy_outlined,
                                              color: Color(0xFF004DFF),
                                            ),
                                            Text(
                                              'Copy',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF004DFF),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      widget.onCopy!();
                                    },
                                  ),
                            SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              child: Container(
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.reply_sharp,
                                          color: Color(0xFF004DFF)),
                                      Text(
                                        'Reply',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF004DFF),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onReply!(widget.message);
                              },
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            if (widget.isMe)
                              GestureDetector(
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.edit,
                                            color: Color(0xFF004DFF)),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF004DFF),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  widget.onReply!(widget.message);
                                },
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
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
  ];

  @override
  Widget build(BuildContext context) {
    final fontSize = 27.0;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
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
                  padding: const EdgeInsets.only(right: 2.0),
                  child: Text(
                    e,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              )),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_horiz,
                color: Color(0xFF99A2AD),
              ),
              onPressed: showEmojiBoard as void Function()?,
              iconSize: fontSize + 3,
            ),
          ),
        ],
      ),
    );
  }
}
