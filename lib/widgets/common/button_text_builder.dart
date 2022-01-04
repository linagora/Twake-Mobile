import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/styles_config.dart';

class ButtonTextBuilder {
  final Key key;
  double widthButton = Dim.widthPercent(90);
  double heightButton = 60.0;
  Color backgroundColor;
  String text = '';
  TextStyle textStyle = StylesConfig.commonTextStyle
      .copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17);
  BorderRadius borderRadius = BorderRadius.all(Radius.circular(16));
  Function? onButtonClick;

  ButtonTextBuilder(this.key,
      {required this.onButtonClick, required this.backgroundColor});

  ButtonTextBuilder setWidth(double widthSize) {
    widthButton = widthSize;
    return this;
  }

  ButtonTextBuilder setHeight(double heightSize) {
    heightButton = heightSize;
    return this;
  }

  ButtonTextBuilder setBackgroundColor(Color bgColor) {
    backgroundColor = bgColor;
    return this;
  }

  ButtonTextBuilder setText(String txt) {
    text = txt;
    return this;
  }

  ButtonTextBuilder setTextStyle(TextStyle txtStyle) {
    textStyle = txtStyle;
    return this;
  }

  ButtonTextBuilder setBorderRadius(BorderRadius radius) {
    borderRadius = radius;
    return this;
  }

  Widget build() {
    return Container(
        width: widthButton,
        height: heightButton,
        child: TextButton(
            onPressed: () => onButtonClick?.call(),
            child: Text(text, style: textStyle),
            style: TextButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: borderRadius))));
  }
}
