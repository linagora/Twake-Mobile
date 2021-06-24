import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

import 'home_channel_tile.dart';

class HomeChannelListWidget extends StatelessWidget {
  const HomeChannelListWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<ChannelsCubit, ChannelsState>(
        bloc: Get.find<ChannelsCubit>(),
        builder: (context, channelState) {
          if (channelState is ChannelsLoadedSuccess) {
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
                  content: channel.lastMessage?.text,
                  imageUrl: channel.icon,
                  dateTime: channel.lastMessage?.date,
                  channelId: channel.id,
                  isPrivate: channel.isPrivate,
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
