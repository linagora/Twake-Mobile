import 'package:flutter/material.dart';
import 'package:twake/widgets/common/named_avatar.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/utils/extensions.dart';

class ChannelThumbnail extends StatelessWidget {
  final String icon;
  final String name;
  final bool isPrivate;
  final double width;
  final double height;
  final double iconSize;

  const ChannelThumbnail({
    Key? key,
    this.icon = '',
    this.name = '',
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
          child: icon.isNotReallyEmpty
              ? TextAvatar(
                  icon,
                  fontSize: iconSize,
                  width: 50,
                  height: 50,
                )
              : NamedAvatar(
                  name: name,
                  size: 50,
                  borderRadius: width / 2,
                  fontColor: Colors.white,
                ),
        ),
        if (isPrivate) Image.asset('assets/images/private.png'),
      ],
    );
  }
}
