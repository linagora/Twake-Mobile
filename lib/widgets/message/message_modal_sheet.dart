import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class MessageModalSheet extends StatefulWidget {
  final String userId;
  final String messageId;
  final int responsesCount;
  final void Function(BuildContext, String, {bool autofocus}) onReply;
  final void Function(BuildContext) onDelete;
  final Function onCopy;
  final bool isThread;
  final BuildContext ctx;

  const MessageModalSheet({
    this.userId,
    this.messageId,
    this.responsesCount,
    this.isThread: false,
    this.onReply,
    this.onDelete,
    this.onCopy,
    this.ctx,
    Key key,
  }) : super(key: key);

  @override
  _MessageModalSheetState createState() => _MessageModalSheetState();
}

class _MessageModalSheetState extends State<MessageModalSheet> {
  bool _emojiVisible = false;
  onEmojiSelected(String emojiCode) {
    BlocProvider.of<SingleMessageBloc>(widget.ctx)
        .add(UpdateReaction(emojiCode: emojiCode));
    FocusManager.instance.primaryFocus.unfocus();
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
    final bool isMe = BlocProvider.of<ProfileBloc>(context).isMe(widget.userId);
    return _emojiVisible
        ? buildEmojiBoard()
        : Container(
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiLine(
                      onEmojiSelected: onEmojiSelected,
                      showEmojiBoard: showEmojiBoard),
                  Divider(),
                  if (!widget.isThread)
                    ListTile(
                      leading: Icon(Icons.reply_sharp),
                      title: Text(
                        'Reply',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onReply(context, widget.messageId,
                            autofocus: true);
                      },
                    ),
                  if (!widget.isThread) Divider(),
                  if (isMe && widget.responsesCount == 0)
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete',
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            .copyWith(color: Colors.red),
                      ),
                      onTap: () {
                        widget.onDelete(context);
                      },
                    ),
                  if (isMe && widget.responsesCount == 0) Divider(),
                  ListTile(
                    leading: Icon(Icons.copy),
                    title: Text(
                      'Copy',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    onTap: widget.onCopy,
                  ),
                ],
              ),
            ),
          );
  }
}

class EmojiLine extends StatelessWidget {
  final Function onEmojiSelected;
  final Function showEmojiBoard;
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
        horizontal: Dim.wm2,
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
                  onEmojiSelected(e);
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
            onPressed: showEmojiBoard,
            iconSize: fontSize + 3,
          ),
        ],
      ),
    );
  }
}
