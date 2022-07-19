import 'package:flutter/cupertino.dart';

class RichTextSpan extends TextSpan {
  final String text;
  final bool isBold;

  const RichTextSpan({required this.text, this.isBold = false});

  TextSpan buildSpan() {
    return TextSpan(
      text: text,
      style: isBold
          ? TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.black,
            )
          : TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.black,
            ),
    );
  }
}
