import 'package:flutter/material.dart';

class HintLine extends StatelessWidget {
  final String text;
  final bool isLarge;
  final FontWeight fontWeight;
  const HintLine({
    Key? key,
    required this.text,
    this.isLarge = false,
    this.fontWeight = FontWeight.w400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      width: MediaQuery.of(context).size.width,
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: isLarge ? 13.0 : 12.0,
          fontWeight: fontWeight,
          color: Colors.black.withOpacity(0.4),
        ),
      ),
    );
  }
}
