import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/users/found_user_tile.dart';
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
        if (state.contactsStateStatus == ChatsStateStatus.done &&
            state.users.length > 0) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];

              return FoundUserTile(
                onTileClick: () {},
                imageUrl: user.picture ?? '',
                name: '${user.fullName}',
                userId: user.id,
              );
            },
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
