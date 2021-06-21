import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

import 'home_channel_tile.dart';

class HomeDirectListWidget extends StatelessWidget {
  const HomeDirectListWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<DirectsCubit, ChannelsState>(
        bloc: Get.find<DirectsCubit>(),
        builder: (context, directState) {
          if (directState is ChannelsLoadedSuccess) {
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 78),
                  child: Container(
                    height: 1,
                    color: Color(0xfff6f6f6),
                  ),
                );
              },
              itemCount: directState.channels.length,
              itemBuilder: (context, index) {
                final channel = directState.channels[index];
                return HomeChannelTile(
                  onHomeChannelTileClick: () =>
                      NavigatorService.instance.navigate(
                    channelId: channel.id,
                    workspaceId: channel.workspaceId,
                  ),
                  title: channel.name,
                  name: channel.lastMessage?.senderName,
                  content: channel.lastMessage?.text,
                  imageUrl: channel.icon,
                  dateTime: channel.lastMessage?.date,
                  channelid: channel.id,
                );
              },
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
