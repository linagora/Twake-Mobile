import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

import 'home_channel_tile.dart';

class HomeChannelListWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _channelsCubit = Get.find<ChannelsCubit>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<ChannelsCubit, ChannelsState>(
        bloc: _channelsCubit,
        buildWhen: (previousState, currentState) =>
            previousState is ChannelsInitial ||
            currentState is ChannelsLoadedSuccess,
        builder: (context, channelState) {
          if (channelState is ChannelsLoadedSuccess) {
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                try {
                  await _channelsCubit.fetch(
                    workspaceId: Globals.instance.workspaceId!,
                    companyId: Globals.instance.companyId,
                  );
                  Get.find<WorkspacesCubit>().fetchMembers();
                  Get.find<BadgesCubit>().fetch();
                } catch (e, ss) {
                  print('Error occured while pull to refresh:\n$e\n$ss');
                } finally {
                  _refreshController.refreshCompleted();
                }
              },
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 78),
                    child: Container(
                      height: 1,
                      color: Color(0xfff6f6f6),
                    ),
                  );
                },
                itemCount: channelState.channels.length,
                itemBuilder: (context, index) {
                  final channel = channelState.channels[index];
                  return HomeChannelTile(
                    onHomeChannelTileClick: () =>
                        NavigatorService.instance.navigate(
                      channelId: channel.id,
                    ),
                    title: channel.name,
                    name: channel.lastMessage?.senderName,
                    content: channel.lastMessage?.body,
                    imageUrl: Emojis.getByName(channel.icon ?? ''),
                    dateTime: channel.lastActivity,
                    channelId: channel.id,
                    isPrivate: channel.isPrivate,
                  );
                },
              ),
            );
          }
          return Align(
            alignment: Alignment.center,
            child: TwakeCircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
