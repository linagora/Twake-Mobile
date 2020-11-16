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
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ImageAvatar(message.sender.img),
            title: Row(children: [
              Text(
                message.sender.username ?? '',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                ' - Online', // TODO figure out how to get status of user
                style: Theme.of(context).textTheme.subtitle2,
              )
            ]),
            trailing: Text(
              DateFormatter.getVerboseDateTime(message.creationDate),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Container(
            child: Text(
              message.content.originalStr ?? '',
              softWrap: true,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
