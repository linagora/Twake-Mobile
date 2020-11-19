import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/utils/emojis.dart';

class TextAvatar extends StatelessWidget {
  final String text;
  final bool emoji;
  final double fontSize;
  TextAvatar(this.text, {this.emoji: false, this.fontSize});

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.headline6;
    if (fontSize != null) style = style.copyWith(fontSize: fontSize);
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        Dim.widthMultiplier * 0.5,
      ),
      child: Container(
        // color: Colors.grey[200],
        margin: EdgeInsets.symmetric(
          vertical: Dim.heightMultiplier,
        ),
        width: Dim.wm9,
        height: Dim.wm9,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            emoji ? Emojis.getClosestMatch(text) : text,
            style: style,
          ),
        ),
      ),
    );
  }
}
