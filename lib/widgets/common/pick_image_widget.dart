import 'package:flutter/material.dart';

typedef OnPickImageWidgetClick = void Function();

class PickImageWidget extends StatelessWidget {
  final double width;
  final double height;
  final OnPickImageWidgetClick? onPickImageWidgetClick;

  const PickImageWidget({this.width = 56, this.height = 56, this.onPickImageWidgetClick}) : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImageWidgetClick,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: Container(
            width: width,
            height: height,
            color: Color(0xfff2f2f6),
            child: Icon(
              Icons.photo_camera_rounded,
              size: 24,
              color: Color(0xff969ca4),
            )),
      ),
    );
  }
}
