import 'package:flutter/material.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/screens/messages_screen.dart';
import 'package:twake_mobile/utils/emojis.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  ChannelTile(this.channel);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          MessagesScreen.route,
          arguments: channel.id,
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Text(
            Emojis.getClosestMatch(channel.icon),
          ),
        ),
        title: Text(channel.name),
        subtitle: Text('${channel.membersCount ?? 'No'} members'),
      ),
    );
  }
}
