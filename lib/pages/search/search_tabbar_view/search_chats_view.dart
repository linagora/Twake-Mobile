import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/channels/channel_item.dart';
import 'package:twake/pages/search/search_tabbar_view/channels/recent_channel_item.dart';
import 'package:twake/widgets/common/no_search_results_widget.dart';

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
              ChatSection(chats: state.chats),
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
            child: Text('Recent channels and contacts',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 15.0, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              scrollDirection: Axis.horizontal,
              itemCount: recentChats.length,
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

  const ChatSection({Key? key, required this.chats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text('Channels',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontSize: 15.0, fontWeight: FontWeight.w600)),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: chats.length,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemBuilder: (context, index) {
            final channel = chats[index];
            return ChannelItemWidget(channel: channel);
          },
        )
      ],
    );
  }
}

class ChatsStatusInformer extends StatelessWidget {
  final ChatsStateStatus status;
  final String searchTerm;
  final Function onResetTap;

  const ChatsStatusInformer(
      {Key? key,
      required this.status,
      required this.searchTerm,
      required this.onResetTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == ChatsStateStatus.loading) {
      return Center(
        child: Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return NoSearchResultsWidget(
        searchTerm: searchTerm, onResetTap: onResetTap);
  }
}
