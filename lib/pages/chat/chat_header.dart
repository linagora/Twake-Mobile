 import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:twake/pages/feed/user_thumbnail.dart';
import 'package:twake/widgets/common/channel_thumbnail.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class ChatHeader extends StatelessWidget {
  final bool isDirect;
  final bool isPrivate;
  final int? membersCount;
  final String? userId;
  final String icon;
  final String name;
  final Function? onTap;

  const ChatHeader({
    Key? key,
    required this.isDirect,
    this.isPrivate = false,
    this.userId,
    this.membersCount,
    this.icon = '',
    this.name = '',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap as void Function()?,
      child: Row(
        children: [
          if (isDirect)
            UserThumbnail(
              userId: userId,
              size: 38.0,
            ),
          if (!isDirect)
            ShimmerLoading(
              key: ValueKey<String>('channel_icon'),
              isLoading: icon.isEmpty,
              width: 38.0,
              height: 38.0,
              child: ChannelThumbnail(
                icon: icon,
                isPrivate: isPrivate,
                width: 38.0,
                height: 38.0,
              ),
            ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  key: ValueKey<String>('name'),
                  isLoading: name.isEmpty,
                  width: 60.0,
                  height: 10.0,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                if (!isDirect)
                  ShimmerLoading(
                    key: ValueKey<String>('membersCount'),
                    isLoading: membersCount == null,
                    width: 50,
                    height: 10,
                    child: Text(
                      membersCount == null
                          ? ''
                          : '${membersCount! > 0 ? membersCount : 'No'} members',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff92929C),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
 
