import 'package:flutter/material.dart';

class HintLine extends StatelessWidget {
  final String text;

  const HintLine({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      width: MediaQuery.of(context).size.width - 24,
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(0.4),
        ),
      ),
    );
  }
}
