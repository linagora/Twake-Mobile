import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';
import 'home_channel_tile.dart';

class HomeDirectListWidget extends StatelessWidget {
  final _refreshController = RefreshController();
  final _directsCubit = Get.find<DirectsCubit>();

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
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: () async {
                await _directsCubit.fetch(
                  workspaceId: 'direct',
                  companyId: Globals.instance.companyId,
                );
                await Future.delayed(Duration(seconds: 1));
                _refreshController.refreshCompleted();
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
                itemCount: directState.channels.length,
                itemBuilder: (context, index) {
                  final channel = directState.channels[index];

                  return FutureBuilder(
                    //  initialData: Account init,
                    future: Get.find<ChannelsCubit>()
                        .fetchMembers(channel: channel)
                        .then((accountList) {
                      List<String> titleU = [];
                      if (accountList.length == 1) {
                        titleU.add(accountList.first.fullName);
                        titleU.add(accountList.first.picture.toString());
                        return titleU;
                      } else {
                        accountList.removeWhere(
                            (account) => account.id == Globals.instance.userId);
                        String title = "";
                        accountList.forEach((account) {
                          title += account.fullName;
                        });
                        titleU.add(title);
                        titleU.add(accountList.first.picture.toString());
                        return titleU;
                      }
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return HomeChannelTile(
                          onHomeChannelTileClick: () =>
                              NavigatorService.instance.navigate(
                            channelId: channel.id,
                            workspaceId: channel.workspaceId,
                          ),
                          title: (snapshot.data as List<String>)[0],
                          name: channel.lastMessage?.senderName,
                          content: channel.lastMessage?.body,
                          imageUrl: (snapshot.data as List<String>)[1],
                          dateTime: channel.lastActivity,
                          channelId: channel.id,
                          isDirect: true,
                        );
                      }
                      return HomeChannelTile(
                        onHomeChannelTileClick: () =>
                            NavigatorService.instance.navigate(
                          channelId: channel.id,
                          workspaceId: channel.workspaceId,
                        ),
                        title: "channel name",
                        name: channel.lastMessage?.senderName,
                        content: channel.lastMessage?.body,
                        imageUrl: null,
                        dateTime: channel.lastActivity,
                        channelId: channel.id,
                        isDirect: true,
                      );
                    },
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
