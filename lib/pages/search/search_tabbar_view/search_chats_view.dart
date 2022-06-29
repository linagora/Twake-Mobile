import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
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
        print(state.recentChats);
        if (state.chatsStateStatus == ChatsStateStatus.done) {
          return SizedBox.expand(
            child: ListView(children: [
              RecentSection(recentChats: state.recentChats),
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
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent channels and people'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: recentChats.length,
              itemBuilder: (context, index) {
                final channel = recentChats[index];
                return RecentChannelItemWidget(channel: channel);
              },
            ),
          )
        ],
      ),
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
