import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/screens/messages_screen.dart';
import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/widgets/common/text_avatar.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  ChannelTile(this.channel);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final provider = Provider.of<MessagesProvider>(context, listen: false);
        provider.clearMessages();
        Navigator.of(context).pushNamed(
          MessagesScreen.route,
          arguments: channel.id,
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.only(bottom: Dim.textMultiplier),
        leading: TextAvatar(
          channel.icon,
          emoji: true,
        ),
        title: Text(
          channel.name,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        ),
        trailing: FittedBox(
          fit: BoxFit.fitWidth,
          // width: Dim.widthPercent(40),
          child: Row(
            children: [
              Text(
                DateFormatter.getVerboseDateTime(channel.lastActivity),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              if (channel.messageUnread != 0) SizedBox(width: Dim.wm2),
              if (channel.messageUnread != 0)
                Chip(
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: Dim.widthMultiplier),
                  label: Text(
                    '${channel.messageUnread}',
                    style: TextStyle(color: Colors.white, fontSize: Dim.tm2()),
                  ),
                  clipBehavior: Clip.antiAlias,
                  backgroundColor: Color.fromRGBO(255, 81, 84, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
