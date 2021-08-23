import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';
import 'home_channel_tile.dart';

class HomeDirectListWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _directsCubit = Get.find<DirectsCubit>();
  final String serchText;

  HomeDirectListWidget({this.serchText = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<DirectsCubit, ChannelsState>(
        bloc: _directsCubit,
        buildWhen: (previousState, currentState) =>
            previousState is ChannelsInitial ||
            currentState is ChannelsLoadedSuccess,
        builder: (context, directState) {
          if (directState is ChannelsLoadedSuccess) {
            //  searching by name
            final channels = serchText.isEmpty
                ? directState.channels
                : directState.channels
                    .where((channel) =>
                        channel.name.toLowerCase().contains(serchText))
                    .toList();
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                try {
                  await _directsCubit.fetch(
                    workspaceId: 'direct',
                    companyId: Globals.instance.companyId,
                  );
                  Get.find<WorkspacesCubit>().fetchMembers();
                  Get.find<BadgesCubit>().fetch();
                } catch (e, ss) {
                  print('Error occured during directs refresh:\n$e\n$ss');
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
                itemCount: channels.length > 0
                    ? channels.length
                    : directState.channels.length,
                itemBuilder: (context, index) {
                  final avatar = channels[index].avatars.first;
                  return HomeChannelTile(
                    onHomeChannelTileClick: () =>
                        NavigatorService.instance.navigate(
                      channelId: channels[index].id,
                    ),
                    title: channels[index].name,
                    name: channels[index].lastMessage?.senderName,
                    content: channels[index].lastMessage?.body,
                    imageUrl: avatar.link,
                    avatars: channels[index].avatars,
                    dateTime: channels[index].lastActivity,
                    channelId: channels[index].id,
                    isDirect: true,
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
