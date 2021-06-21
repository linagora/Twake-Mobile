import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnEnableButtonWidgetClick = void Function();

class EnableButtonWidget extends StatelessWidget {
  final String text;
  final bool isEnable;
  final OnEnableButtonWidgetClick? onEnableButtonWidgetClick;

  const EnableButtonWidget(
      {required this.text, required this.isEnable, this.onEnableButtonWidgetClick})
      : super();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: isEnable ? onEnableButtonWidgetClick : null,
      child: Text(
        text,
        style: TextStyle(
          color: isEnable ? Color(0xff004dff) : Color(0xff969ca4),
          fontSize: 17,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
