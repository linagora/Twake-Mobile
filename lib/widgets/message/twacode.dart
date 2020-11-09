import 'package:flutter/material.dart';

class Twacode extends StatelessWidget {
  final List<dynamic> code;
  Twacode(this.code);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> elements = List();
    for (var i = 0; i < elements.length; i++) {
      elements.add(
        TextSpan(text: elements[i] as String),
      );
    }

    return RichText(
      text: TextSpan(
        children: [],
      ),
    );
  }
}
