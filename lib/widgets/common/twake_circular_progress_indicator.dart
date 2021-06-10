import 'package:flutter/material.dart';

class TwakeCircularProgressIndicator extends StatelessWidget {
  final double? width;
  final double? height;

  const TwakeCircularProgressIndicator({this.width, this.height}) : super();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 36,
      height: height ?? 36,
      child: CircularProgressIndicator(
        color: Color(0xff004dff),
      ),
    );
  }
}
