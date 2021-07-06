import 'package:flutter/material.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/random_hex_color.dart';

class NamedAvatar extends StatelessWidget {
  const NamedAvatar({
    Key? key,
    this.size = 60.0,
    this.name = '',
    this.backgroundColor = Colors.transparent,
    this.fontColor = Colors.black,
    this.borderColor = Colors.transparent,
    this.borderRadius = 0.0,
  }) : super(key: key);

  final double size;
  final String name;
  final Color backgroundColor;
  final Color fontColor;
  final Color borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    String charactersToShow = '';
    if (name.isNotReallyEmpty) {
      charactersToShow = name[0].toUpperCase();

      final splitWords = name.split(' ');
      if (splitWords.length > 1) {
        charactersToShow = '$charactersToShow${splitWords[1][0].toUpperCase()}';
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: backgroundColor != Colors.transparent
          ? BoxDecoration(
              color: backgroundColor,
              border: Border.all(width: 2.0, color: borderColor),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius),
              ),
            )
          : BoxDecoration(
              border: Border.all(width: 2.0, color: borderColor),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius),
              ),
              gradient: randomGradient(),
            ),
      padding: EdgeInsets.all(5.0),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          charactersToShow,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: fontColor,
          ),
        ),
      ),
    );
  }
}
