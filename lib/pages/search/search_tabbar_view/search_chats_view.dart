import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_settings.dart';
import 'package:twake/pages/search/search_tabbar_view/channels/channel_item.dart';
import 'package:twake/pages/search/search_tabbar_view/channels/chats_status_informer.dart';
import 'package:twake/pages/search/search_tabbar_view/channels/recent_channel_item.dart';
import 'package:twake/utils/translit.dart';

class SearchChatsView extends StatefulWidget {
  @override
  State<SearchChatsView> createState() => _SearchChatsViewState();
}

class _SearchChatsViewState extends State<SearchChatsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        if (state.chatsStateStatus == ChatsStateStatus.done &&
            state.chats.isEmpty) {
          return ChatsStatusInformer(
              status: state.chatsStateStatus,
              searchTerm: state.searchTerm,
              onResetTap: () => Get.find<SearchCubit>().resetSearch());
        }

        if (state.chatsStateStatus == ChatsStateStatus.done) {
          return SizedBox.expand(
            child: ListView(children: [
              if (state.searchTerm.isEmpty)
                RecentSection(recentChats: state.recentChats),
              BlocBuilder<DirectsCubit, ChannelsState>(
                  bloc: Get.find<DirectsCubit>(),
                  builder: (context, directState) {
                    List<Channel> direct = [];

                    if (directState is ChannelsLoadedSuccess) {
                      direct = state.searchTerm.isEmpty
                          ? directState.channels
                          : directState.channels.where((channel) {
                              return channel.name
                                      .toLowerCase()
                                      .contains(state.searchTerm) ||
                                  channel.name.toLowerCase().contains(
                                      translitCyrillicToLatin(
                                          state.searchTerm));
                            }).toList();
                    }

                    return ChatSection(
                      chats: state.chats,
                      direct: direct,
                      displayUsers: state.searchTerm.isNotEmpty,
                    );
                  }),
            ]),
          );
        }

        return ChatsStatusInformer(
            status: state.chatsStateStatus,
            searchTerm: state.searchTerm,
            onResetTap: () => Get.find<SearchCubit>().resetSearch());
      },
    );
  }
}

class RecentSection extends StatelessWidget {
  final List<Channel> recentChats;

  const RecentSection({Key? key, required this.recentChats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, top: 10),
            child: Text(AppLocalizations.of(context)!.searchChatsRecentHeader,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 15.0, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              scrollDirection: Axis.horizontal,
              itemCount: recentChats.length < displayLimitOfRecentChats
                  ? recentChats.length
                  : displayLimitOfRecentChats,
              itemBuilder: (context, index) {
                final channel = recentChats[index];
                return RecentChannelItemWidget(channel: channel);
              },
            ),
          ),
          Container(
            height: 1.0,
            margin: EdgeInsets.symmetric(horizontal: 15),
            color: Colors.grey.shade300,
          )
        ],
      ),
    );
  }
}

class ChatSection extends StatelessWidget {
  final List<Channel> chats;
  final List<Channel> direct;
  final bool displayUsers;

  const ChatSection(
      {Key? key,
      required this.chats,
      required this.direct,
      required this.displayUsers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Channel> list = [];

    if (displayUsers) {
      list.addAll(direct);
      list.addAll(chats);
    } else {
      list.addAll(chats);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text(AppLocalizations.of(context)!.searchChatsHeader,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontSize: 15.0, fontWeight: FontWeight.w600)),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: list.length,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemBuilder: (context, index) {
            final item = list[index];

            return ChannelItemWidget(channel: item);
          },
        )
      ],
    );
  }
}
