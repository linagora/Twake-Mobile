import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/utils/emojis.dart';
import 'package:twake_mobile/widgets/common/emoji_piker_keyboard.dart';

class MessageModalSheet extends StatefulWidget {
  final Message message;
  final void Function(BuildContext) onReply;
  final void Function(BuildContext) onEdit;
  final bool isThread;
  const MessageModalSheet(
    this.message, {
    this.isThread: false,
    this.onReply,
    this.onEdit,
    Key key,
  }) : super(key: key);

  @override
  _MessageModalSheetState createState() => _MessageModalSheetState();
}

class _MessageModalSheetState extends State<MessageModalSheet> {
  bool emojiBoardHidden = true;
  onEmojiSelected(String emojiCode, {bool reverse: false}) {
    setState(() {
      emojiBoardHidden = true;
    });

    String userId = Provider.of<ProfileProvider>(context, listen: false)
        .currentProfile
        .userId;
    if (reverse) {
      emojiCode = Emojis().reverseLookup(emojiCode);
      emojiCode = ':$emojiCode:';
    }

    widget.message.updateReactions(emojiCode, userId);
  }

  void toggleEmojiBoard() {
    setState(() {
      emojiBoardHidden = !emojiBoardHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = Provider.of<ProfileProvider>(context, listen: false)
        .isMe(widget.message.sender.id);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Show edit only if the sender of the message is the person,
          /// who's currently logged in
          if (emojiBoardHidden) EmojiLine(onEmojiSelected, toggleEmojiBoard),
          if (emojiBoardHidden) Divider(),
          if (emojiBoardHidden)
            ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              onTap: () {
                widget.onEdit(context);
              },
            ),
          if (isMe && emojiBoardHidden) Divider(),
          if (!widget.isThread && emojiBoardHidden)
            ListTile(
              leading: Icon(Icons.reply_sharp),
              title: Text('Reply'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onReply(context);
              },
            ),
          if (!widget.isThread && emojiBoardHidden) Divider(),
          if (isMe && emojiBoardHidden)
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {},
            ),
          if (isMe && emojiBoardHidden) Divider(),
          ListTile(
            leading: Icon(Icons.copy),
            title: Text(
              'Copy',
            ),
            onTap: () {},
          ),
          Offstage(
              offstage: emojiBoardHidden,
              child: EmojiPickerKeyboard(onEmojiPicked: (emoji) {
                onEmojiSelected(emoji.emoji, reverse: true);
              })),
        ],
      ),
    );
  }
}

class EmojiLine extends StatelessWidget {
  final Function emojiPicked;
  final Function toggleEmojiBoard;
  EmojiLine(this.emojiPicked, this.toggleEmojiBoard);
  static const EMOJISET = [
    ':smiley:',
    ':sweat_smile:',
    ':thumbsup:',
    ':thumbsdown:',
    ':laughing:',
    ':heart:',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dim.heightMultiplier,
        horizontal: Dim.wm2,
      ),
      child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...EMOJISET.map((e) => InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    emojiPicked(context, e);
                  },
                  child: Text(
                    Emojis.getByName(e),
                    style: Theme.of(context).textTheme.headline3,
                  ),
                )),
            IconButton(
              icon: Icon(Icons.tag_faces),
              onPressed: toggleEmojiBoard,
              iconSize: Dim.tm4(),
            ),
          ]),
    );
  }
}
