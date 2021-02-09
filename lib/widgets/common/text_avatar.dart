import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:auto_size_text/auto_size_text.dart';

class TextAvatar extends StatelessWidget {
  final String text;
  final double fontSize;
  final double width;
  final double height;

  TextAvatar(
    this.text, {
    this.fontSize,
    this.width = 32.0,
    this.height = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius:  BorderRadius.circular(
          Dim.widthMultiplier * 0.5,
        ),
      ),
      child: AutoSizeText(
        text,
        style: TextStyle(fontSize: fontSize ?? Dim.tm3()),
      ),
    );
  }
}