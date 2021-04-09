import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/pages/feed/channel_tile.dart';

class Channels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsBloc, ChannelState>(
      buildWhen: (_, current) =>
          current is ChannelsLoading ||
          current is ChannelsLoaded ||
          current is ChannelsEmpty,
      builder: (context, state) {
        var channels = <Channel>[];
        if (state is ChannelsLoaded) {
          channels = state.channels;
        }
        return Container(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 12.0),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              print('Last message: ${channel.lastMessage}');
              return ChannelTile(
                id: channel.id,
                name: channel.name,
                icon: channel.icon,
                hasUnread: channel.hasUnread == 1,
                isPrivate: channel.visibility != null &&
                    channel.visibility == 'private',
                lastActivity: channel.lastActivity,
                lastMessage: channel.lastMessage,
                messagesUnread: channel.messagesUnread,
              );
            },
          ),
        );
      },
    );
  }
}
