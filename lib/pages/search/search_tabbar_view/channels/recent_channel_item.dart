import 'package:flutter/material.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_file_widget.dart';
import 'package:twake/widgets/common/image_widget.dart';

class RecentChannelItemWidget extends StatelessWidget {
  final Channel channel;

  const RecentChannelItemWidget({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 58,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ImageWidget(
                    name: channel.name,
                    imageType: ImageType.common,
                    size: 56,
                    imageUrl: channel.icon ?? '',
                  ),
                ),
                SizedBox.shrink(),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
                channel.name.length > maxTextLength
                    ? channel.name.substring(0, maxTextLength)
                    : channel.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 10)),
            SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }
}
