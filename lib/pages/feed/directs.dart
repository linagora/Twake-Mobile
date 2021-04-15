import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/direct.dart';
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
        final userId = ProfileBloc.userId;

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
            padding: EdgeInsets.only(top: 12.0, bottom: 80.0),
            itemCount: directs.length,
            itemBuilder: (context, index) {
              final direct = directs[index];
              print('User id: $userId');
              print('Direct id: ${direct.id}');
              print('Members: ${direct.members}');
              final memberId = direct.members.firstWhere((id) => id != userId);
              return DirectTile(
                key: ValueKey(direct.id),
                id: direct.id,
                name: direct.name,
                memberId: memberId,
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
