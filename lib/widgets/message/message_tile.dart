import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';

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
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ImageAvatar(message.sender.img),
        title: Padding(
          padding: EdgeInsets.only(top: Dim.tm2(decimal: -.5)),
          child: RichText(
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
        ),
        subtitle: Container(
          padding: EdgeInsets.only(top: Dim.heightMultiplier),
          child: Text(
            message.content.originalStr ?? '',
            softWrap: true,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        // trailing: Text(
        // DateFormatter.getVerboseDateTime(message.creationDate),
        // style: Theme.of(context).textTheme.subtitle2,
        // ),
      ),
    );
  }
}
