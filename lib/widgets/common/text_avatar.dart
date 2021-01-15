import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/utils/emojis.dart';

class TextAvatar extends StatelessWidget {
  final String text;
  final bool emoji;
  final double fontSize;
  TextAvatar(this.text, {this.emoji: false, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        Dim.widthMultiplier * 0.5,
      ),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: FittedBox(
          child: Text(
            emoji ? Emojis.getByName(text) : text,
            style: TextStyle(fontSize: fontSize ?? Dim.tm3()),
          ),
        ),
      ),
    );
  }
}
