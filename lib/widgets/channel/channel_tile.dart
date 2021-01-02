import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/channel.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/text_avatar.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  ChannelTile(this.channel);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Logger().d('BEFORE SELECTION ChannelId: ${channel.toJson()}');
        BlocProvider.of<ChannelsBloc>(context).add(
          ChangeSelectedChannel(channel.id),
        );
        // Navigator.of(context).pushNamed(Routes.messages);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MessagesPage(),
        ));
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
          child: Row(
            children: [
              Text(
                DateFormatter.getVerboseDateTime(channel.lastActivity),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              if (channel.messagesUnread != 0) SizedBox(width: Dim.wm2),
              if (channel.messagesUnread != 0)
                Chip(
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: Dim.widthMultiplier),
                  label: Text(
                    '${channel.messagesUnread}',
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
