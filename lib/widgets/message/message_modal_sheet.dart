import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/utils/emojis.dart';

class MessageModalSheet extends StatefulWidget {
  final String userId;
  final String messageId;
  final int responsesCount;
  final void Function(BuildContext, String) onReply;
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
  onEmojiSelected(String emojiCode, {bool reverse: false}) {
    if (reverse) {
      emojiCode = Emojis().reverseLookup(emojiCode);
      if (emojiCode != null) {
        emojiCode = ':$emojiCode:';
      } else {
        return;
      }
    }

    BlocProvider.of<SingleMessageBloc>(widget.ctx)
        .add(UpdateReaction(userId: widget.userId, emojiCode: emojiCode));
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = BlocProvider.of<ProfileBloc>(context).isMe(widget.userId);
    return Container(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmojiLine(onEmojiSelected),
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
                  widget.onReply(context, widget.messageId);
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
            if (isMe) Divider(),
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
  final Function emojiPicked;
  EmojiLine(this.emojiPicked);
  static const EMOJISET = [
    ':smiley:',
    ':smile:',
    ':sweat_smile:',
    ':wink:',
    ':yum:',
    ':laughing:',
    ':rage:',
    ':cry:',
    ':persevere:',
    ':disappointed:',
    ':thumbsup:',
    ':thumbsdown:',
    ':ok_hand:',
    'raised_hand_with_fingers_splayed',
    ':heart:',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Dim.heightMultiplier,
        horizontal: Dim.wm2,
      ),
      constraints: BoxConstraints(maxHeight: Dim.hm7),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...EMOJISET.map((e) => InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  emojiPicked(e);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    Emojis().getByName(e),
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
