import 'package:flutter/material.dart';
import 'package:twake/widgets/common/text_avatar.dart';

class ChannelThumbnail extends StatelessWidget {
  final String icon;
  final bool isPrivate;
  final double width;
  final double height;
  final double iconSize;

  const ChannelThumbnail({
    Key? key,
    this.icon = '',
    this.isPrivate = false,
    this.width = 60.0,
    this.height = 60.0,
    this.iconSize = 28.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xfff5f5f5),
          ),
          child: TextAvatar(
            icon,
            fontSize: iconSize,
            width: 50,
            height: 50,
          ),
        ),
        if (isPrivate) Image.asset('assets/images/private.png'),
      ],
    );
  }
}
