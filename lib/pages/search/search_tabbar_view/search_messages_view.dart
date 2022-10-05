import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/messages/message_item.dart';
import 'package:twake/pages/search/search_tabbar_view/messages/messages_status_informer.dart';
import 'package:twake/repositories/search_repository.dart';

class SearchMessagesView extends StatefulWidget {
  @override
  State<SearchMessagesView> createState() => _SearchMessagesViewState();
}

class _SearchMessagesViewState extends State<SearchMessagesView>
    with AutomaticKeepAliveClientMixin<SearchMessagesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<SearchCubit, SearchState>(
      bloc: Get.find<SearchCubit>(),
      builder: (context, state) {
        // if no results and on search tern display empty icon
        if (state.messages.isEmpty && state.searchTerm.isEmpty) {
          return MessagesStatusInformer(
              status: MessagesStateStatus.init,
              searchTerm: state.searchTerm,
              onResetTap: () => Get.find<SearchCubit>().resetSearch());
        }

        if (state.messagesStateStatus == MessagesStateStatus.done &&
            state.messages.isNotEmpty) {
          return SizedBox.expand(
            child: ListView(children: [
              MessagesSection(
                searchTerm: state.searchTerm,
                messages: state.messages,
              )
            ]),
          );
        }

        return MessagesStatusInformer(
            status: state.messagesStateStatus,
            searchTerm: state.searchTerm,
            onResetTap: () => Get.find<SearchCubit>().resetSearch());
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MessagesSection extends StatelessWidget {
  final List<SearchMessage> messages;
  final String searchTerm;

  const MessagesSection(
      {Key? key, required this.messages, required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text('Messages',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontSize: 15.0, fontWeight: FontWeight.w600)),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: messages.length,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemBuilder: (context, index) {
            return MessageItem(
              searchTerm: searchTerm,
              message: messages[index].message,
              channel: messages[index].channel,
            );
          },
        )
      ],
    );
  }
}
