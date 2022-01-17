import 'package:auto_size_text/auto_size_text.dart';
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
      child: AutoSizeText(
        text,
        maxFontSize: 17,
        minFontSize: 12,
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
