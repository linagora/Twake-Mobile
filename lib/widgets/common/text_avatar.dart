import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class TextAvatar extends StatelessWidget {
  final String text;
  final double fontSize;
  final double width;
  final double height;

  TextAvatar(
    this.text, {
    this.fontSize,
    this.width = 30.0,
    this.height = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        Dim.widthMultiplier * 0.5,
      ),
      child: Container(
        width: width,
        height: height,
        child: FittedBox(
          alignment: Alignment.center,
          fit: BoxFit.cover,
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize ?? Dim.tm3()),
          ),
        ),
      ),
    );
  }
}
