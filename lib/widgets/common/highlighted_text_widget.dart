import 'package:flutter/material.dart';

/// widget that highlights search term in text
class HighlightedTextWidget extends StatelessWidget {
  final String text;
  final String searchTerm;
  final TextStyle textStyle;
  final TextStyle highlightStyle;
  final TextOverflow textOverflow;
  final int maxLines;

  const HighlightedTextWidget(
      {Key? key,
      required this.text,
      required this.searchTerm,
      required this.textStyle,
      required this.highlightStyle,
      required this.textOverflow,
      required this.maxLines})
      : super(key: key);

  @override
  build(BuildContext context) {
    if (searchTerm.isEmpty) {
      return Text(
        text,
        style: textStyle,
        maxLines: maxLines,
        overflow: textOverflow,
      );
    }

    final String textLC = text.toLowerCase();
    final String searchTermLC = searchTerm.toLowerCase();

    List<InlineSpan> children = [];

    int startIndex = 0;
    int currentIndex = 0;

    while (currentIndex < textLC.length) {
      bool found = false;
      int nearestPosIndex = 10000;

      int at;
      if ((at = textLC.indexOf(searchTermLC, currentIndex)) >= 0) {
        if (at < nearestPosIndex) {
          found = true;
          nearestPosIndex = at;
        }
      }

      if (found) {
        if (startIndex < nearestPosIndex) {
          children.add(TextSpan(
              text: text.substring(startIndex, nearestPosIndex),
              style: textStyle));

          startIndex = nearestPosIndex;
        }

        children.add(TextSpan(
            text: text.substring(
                startIndex, nearestPosIndex + searchTermLC.length),
            style: highlightStyle));

        startIndex = currentIndex = nearestPosIndex + searchTermLC.length;
      } else {
        children.add(TextSpan(
            text: text.substring(startIndex, textLC.length), style: textStyle));
        break;
      }
    }

    return RichText(
      text: TextSpan(children: children, style: textStyle),
      maxLines: maxLines,
      overflow: textOverflow,
    );
  }
}
