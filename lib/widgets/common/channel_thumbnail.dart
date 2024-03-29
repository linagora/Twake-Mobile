import 'package:flutter/material.dart';
import 'package:twake/widgets/common/named_avatar.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/user_thumbnail.dart';

class ChannelThumbnail extends StatelessWidget {
  final String icon;
  final String name;
  final bool isPrivate;
  final bool isDirect;
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
    this.isDirect = false,
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
          child: (icon.isNotReallyEmpty && !isDirect)
              ? icon.isNotReallyEmpty
                  ? TextAvatar(
                      icon,
                      fontSize: iconSize,
                      width: (width * 85) / 100,
                      height: (height * 85) / 100,
                    )
                  : NamedAvatar(
                      name: name,
                      size: (width * 85) / 100,
                      borderRadius: width / 2,
                      fontColor: Colors.white,
                    )
              : icon.isNotReallyEmpty
                  ? UserThumbnail(
                      thumbnailUrl: icon,
                      userName: name,
                      size: (width * 85) / 100,
                    )
                  : NamedAvatar(
                      name: name,
                      size: (width * 85) / 100,
                      borderRadius: width / 2,
                      fontColor: Colors.white,
                    ),
        ),
        if (isPrivate) Image.asset('assets/images/private.png'),
      ],
    );
  }
}
