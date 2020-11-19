import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/models/message.dart';
// import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/common/reaction.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  MessageTile(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dim.maxScreenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: Dim.wm2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageAvatar(message.sender.img),
          SizedBox(width: Dim.wm2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: message.sender.firstName != null
                          ? '${message.sender.firstName} ${message.sender.lastName}'
                          : (message.sender.username ?? ''),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    TextSpan(
                      text:
                          ' - Online', // TODO figure out how to get status of user
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: Dim.heightMultiplier),
                width: Dim.widthPercent(73),
                child: Text(
                  message.content.originalStr ?? '',
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              SizedBox(height: Dim.hm2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (message.reactions.isNotEmpty)
                    ...(message.reactions as Map<String, dynamic>)
                        .keys
                        .map((r) {
                      return Reaction(
                        r,
                        (message.reactions as Map<String, dynamic>)[r]['count'],
                      );
                    }),
                  if (message.responsesCount != null)
                    Text(
                      'See all answers (${message.responsesCount})',
                      style: StylesConfig.miniPurple,
                    )
                ],
              ),
              // trailing: Text(
              // DateFormatter.getVerboseDateTime(message.creationDate),
              // style: Theme.of(context).textTheme.subtitle2,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
