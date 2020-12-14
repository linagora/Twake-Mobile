// import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';

class EmojiPickerKeyboard extends StatelessWidget {
  final Function onEmojiPicked;

  const EmojiPickerKeyboard({
    @required this.onEmojiPicked,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Container(child: Text('Not implemented yet'));
  // EmojiPicker(
  // rows: 4,
  // columns: 7,
  // onEmojiSelected: (emoji, category) => onEmojiPicked(emoji),
  // );
}
