import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/image_widget.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final Channel channel;

  const MessageItem({Key? key, required this.message, required this.channel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigate(
          channelId: message.channelId,
        );
      },
      child: Container(
        width: 58,
        margin: const EdgeInsets.only(right: 8, bottom: 10),
        color: Colors.transparent,
        child: Row(
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
                    name: message.username ?? '',
                    imageType: ImageType.common,
                    size: 56,
                    imageUrl: message.picture ?? '',
                  ),
                ),
                SizedBox.shrink(),
              ],
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(channel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                      Text(DateFormatter.getVerboseTime(message.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontSize: 15)),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Text(message.firstName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontSize: 15)),
                  Text(message.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
