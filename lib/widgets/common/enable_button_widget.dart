import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnEnableButtonWidgetClick = void Function();

class EnableButtonWidget extends StatelessWidget {
  final String text;
  final bool isEnable;
  final OnEnableButtonWidgetClick? onEnableButtonWidgetClick;

  const EnableButtonWidget(
      {required this.text,
      required this.isEnable,
      this.onEnableButtonWidgetClick})
      : super();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: isEnable ? onEnableButtonWidgetClick : null,
      child: Text(
        text,
        style: isEnable
            ? Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontWeight: FontWeight.w500, fontSize: 17)
            : Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(fontWeight: FontWeight.w500, fontSize: 17),
      ),
    );
  }
}
