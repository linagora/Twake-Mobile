import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/online_status_circle.dart';

typedef OnHomeChannelTileClick = void Function();

class HomeChannelTile extends StatelessWidget {
  final String title;
  final String? name;
  final String? content;
  final String? imageUrl;
  final List<Avatar> avatars;
  final int? dateTime;
  final OnHomeChannelTileClick? onHomeChannelTileClick;
  final String channelId;
  final bool isPrivate;
  final bool isDirect;

  const HomeChannelTile(
      {required this.title,
      this.name,
      this.content,
      this.imageUrl,
      this.dateTime,
      this.avatars = const [],
      this.onHomeChannelTileClick,
      required this.channelId,
      this.isPrivate = false,
      this.isDirect = false})
      : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onHomeChannelTileClick,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ImageWidget(
                  imageType: isDirect ? ImageType.common : ImageType.channel,
                  imageUrl: imageUrl ?? '',
                  isPrivate: isPrivate,
                  name: title,
                  size: 54,
                  avatars: avatars,
                  stackSize: 35,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                if (isDirect && avatars.length == 1)
                  Positioned(
                      top: 2,
                      left: 36,
                      child: OnlineStatusCircle(
                        channelId: channelId,
                        size: 18,
                      ))
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline1),
                        ),
                        Text(
                          DateFormatter.getVerboseTimeForHomeTile(dateTime),
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 13),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: Dim.widthPercent(70),
                            ),
                            child: Text(
                              name ?? 'This channel is empty',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                          Spacer(),
                          BadgesCount(
                            type: BadgeType.channel,
                            id: channelId,
                            key: ValueKey(channelId),
                            isTitleVisible: false,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        content ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
