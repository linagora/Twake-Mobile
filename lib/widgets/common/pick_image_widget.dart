import 'package:flutter/material.dart';

typedef OnPickImageWidgetClick = void Function();

class PickImageWidget extends StatelessWidget {
  final double width;
  final double height;
  final OnPickImageWidgetClick? onPickImageWidgetClick;

  const PickImageWidget(
      {this.width = 56, this.height = 56, this.onPickImageWidgetClick})
      : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImageWidgetClick,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.secondary,
            child: Icon(
              Icons.photo_camera_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.secondaryContainer,
            )),
      ),
    );
  }
}
