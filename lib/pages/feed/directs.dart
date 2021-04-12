import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/pages/feed/channel_tile.dart';
import 'package:twake/pages/feed/direct_tile.dart';

class Directs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectsBloc, ChannelState>(
      buildWhen: (_, current) =>
      current is ChannelsLoading ||
          current is ChannelsLoaded ||
          current is ChannelsEmpty,
      builder: (context, state) {
        var directs = <Direct>[];
        if (state is ChannelsLoaded) {
          directs = state.channels;
        }
        return RefreshIndicator(
          onRefresh: () {
            BlocProvider.of<DirectsBloc>(context)
                .add(ReloadChannels(forceFromApi: true));
            BlocProvider.of<NotificationBloc>(context)
                .add(ReinitSubscriptions());
            return Future.delayed(Duration(seconds: 1));
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 12.0),
            itemCount: directs.length,
            itemBuilder: (context, index) {
              final direct = directs[index];
              return DirectTile(
                id: direct.id,
                name: direct.name,
                members: direct.members,
                hasUnread: direct.hasUnread == 1,
                lastActivity: direct.lastActivity,
                lastMessage: direct.lastMessage,
                messagesUnread: direct.messagesUnread,
              );
            },
          ),
        );
      },
    );
  }
}
