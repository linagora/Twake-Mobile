import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class TextAvatar extends StatelessWidget {
  final String text;
  final double fontSize;
  TextAvatar(this.text, {this.fontSize});

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
            text,
            style: TextStyle(fontSize: fontSize ?? Dim.tm3()),
          ),
        ),
      ),
    );
  }
}
