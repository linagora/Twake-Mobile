import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  MessageTile(this.message);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0.3 * DimensionsConfig.heightMultiplier,
          horizontal: DimensionsConfig.widthMultiplier,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageAvatar(message.sender.img),
            Padding(
              padding: EdgeInsets.only(left: DimensionsConfig.widthMultiplier),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.sender.username ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(
                          message.creationDate * 1000, // TODO format with intl
                        ).toString() ??
                        '',
                    softWrap: true,
                  ),
                  Container(
                    width: 70 * DimensionsConfig.widthMultiplier,
                    child: Text(
                      message.content.originalStr ?? '',
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
