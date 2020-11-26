import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';

class EmojiPickerKeyboard extends StatelessWidget {
  final Function onEmojiPicked;

  const EmojiPickerKeyboard({
    @required this.onEmojiPicked,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => EmojiPicker(
        rows: 4,
        columns: 9,
        onEmojiSelected: (emoji, category) => onEmojiPicked(emoji.emoji),
      );
}
