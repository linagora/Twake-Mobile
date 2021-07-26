import 'package:flutter/material.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/random_hex_color.dart';

class NamedAvatar extends StatelessWidget {
  final double size;
  final String name;
  final Color backgroundColor;
  final Color fontColor;
  final Color borderColor;
  final double borderRadius;
  final String username;
  final BoxShape boxShape;
  const NamedAvatar({
    Key? key,
    this.size = 60.0,
    this.name = '',
    this.username = '',
    this.backgroundColor = Colors.transparent,
    this.fontColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.borderRadius = 0.0,
    this.boxShape = BoxShape.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //   print(name);
    //  print(name.hashCode % 360);
    //  print((name.hashCode % 360 - 360).toDouble().abs());
    String charactersToShow = '';
    if (name.isNotReallyEmpty) {
      charactersToShow = name[0].toUpperCase();

      final splitWords = name.split(' ');
      if (splitWords.length > 1) {
        final secondWord = splitWords[1];
        if (secondWord.isNotReallyEmpty) {
          charactersToShow =
              '$charactersToShow${splitWords[1][0].toUpperCase()}';
        }
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: backgroundColor != Colors.transparent
          ? BoxDecoration(
              shape: boxShape,
              color: backgroundColor,
            )
          : BoxDecoration(
              shape: boxShape,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: userColors(),
              ), // TODO: del old randomGradient()?,
            ),
      padding: EdgeInsets.all(5.0),
      alignment: Alignment.center,
      child: SizedBox.expand(
        child: FittedBox(
          child: Text(
            charactersToShow,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: fontColor,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> userColors() {
    return [
      username == ""
          ? HSLColor.fromAHSL(1, name.hashCode % 360, 0.9, 0.7).toColor()
          : HSLColor.fromAHSL(1, username.hashCode % 360, 0.9, 0.7).toColor(),
      username == ""
          ? HSLColor.fromAHSL(
                  1, (name.hashCode % 360 - 60).toDouble().abs(), 0.9, 0.7)
              .toColor()
          : HSLColor.fromAHSL(
                  1, (username.hashCode % 360 - 60).toDouble().abs(), 0.9, 0.7)
              .toColor()
    ];
  }
}
