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
import 'package:twake/utils/translit.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

import 'home_channel_tile.dart';

class HomeChannelListWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _channelsCubit = Get.find<ChannelsCubit>();
  final String serchText;

  HomeChannelListWidget({this.serchText = ""});
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
            //  searching by name and description
            final channels = serchText.isEmpty
                ? channelState.channels
                : channelState.channels.where((channel) {
                    return channel.name.toLowerCase().contains(serchText) ||
                        channel.name
                            .toLowerCase()
                            .contains(translitCyrillicToLatin(serchText)) ||
                        (channel.description
                                ?.toLowerCase()
                                .contains(serchText) ??
                            false);
                  }).toList();
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
                        color: Theme.of(context).colorScheme.secondaryVariant),
                  );
                },
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  return HomeChannelTile(
                    onHomeChannelTileClick: () =>
                        NavigatorService.instance.navigate(
                      channelId: channels[index].id,
                    ),
                    title: channels[index].name,
                    name: channels[index].lastMessage?.senderName,
                    content: channels[index].lastMessage?.body,
                    imageUrl: Emojis.getByName(channels[index].icon ?? ''),
                    dateTime: channels[index].lastActivity,
                    channelId: channels[index].id,
                    isPrivate: channels[index].isPrivate,
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
