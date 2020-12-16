import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:flutter/material.dart';

class EmojiPickerKeyboard extends StatelessWidget {
  final Function onEmojiPicked;

  const EmojiPickerKeyboard({
    @required this.onEmojiPicked,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      // Container(child: Text('Not implemented yet'));
      EmojiKeyboard(
        onEmojiSelected: (emoji) => onEmojiPicked(emoji),
      );
  // EmojiPicker(
  // rows: 4,
  // columns: 7,
  // onEmojiSelected: (emoji, category) => onEmojiPicked(emoji),
  // );
}
