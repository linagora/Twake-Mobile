/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
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
        List<Channel?>? channels = <Channel>[];
        if (state is ChannelsLoaded) {
          channels = state.channels as List<Channel?>?;
        }
        return RefreshIndicator(
          onRefresh: () {
            BlocProvider.of<ChannelsBloc>(context)
                .add(ReloadChannels(forceFromApi: true));
            BlocProvider.of<NotificationBloc>(context)
                .add(ReinitSubscriptions());
            return Future.delayed(Duration(seconds: 1));
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 12.0, bottom: 80.0),
            itemCount: channels!.length,
            itemBuilder: (context, index) {
              final channel = channels![index]!;
              return ChannelTile(
                key: ValueKey(channel.id),
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
 */
