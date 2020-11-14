import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/screens/messages_screen.dart';
import 'package:twake_mobile/utils/emojis.dart';
import 'package:twake_mobile/widgets/common/text_avatar.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  ChannelTile(this.channel);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(
              MessagesScreen.route,
              arguments: channel.id,
            )
            .then(
              (_) => Provider.of<MessagesProvider>(context, listen: false)
                  .clearMessages(),
            );
      },
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(vertical: DimensionsConfig.heightMultiplier),
        leading: TextAvatar(
            channel.icon == null ? '' : Emojis.getClosestMatch(channel.icon)),
        title: Text(
          channel.name,
          style: Theme.of(context).textTheme.headline6,
        ),
        trailing: channel.messageUnread == 0
            ? Text('')
            : Chip(
                label: Text(
                  '${channel.messageUnread}',
                  style: Theme.of(context).textTheme.button,
                ),
                clipBehavior: Clip.antiAlias,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
      ),
    );
  }
}
