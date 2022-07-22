import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/search_cubit/search_state.dart';
import 'package:twake/pages/search/search_tabbar_view/messages/message_item.dart';
import 'package:twake/repositories/search_repository.dart';
import 'package:twake/widgets/common/no_search_results_widget.dart';

class SearchMessagesView extends StatefulWidget {
  @override
  State<SearchMessagesView> createState() => _SearchMessagesViewState();
}

class _SearchMessagesViewState extends State<SearchMessagesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
}

class MessagesSection extends StatelessWidget {
  final List<SearchMessage> messages;

  const MessagesSection({Key? key, required this.messages}) : super(key: key);

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
              message: messages[index].message,
              channel: messages[index].channel,
            );
          },
        )
      ],
    );
  }
}

class MessagesStatusInformer extends StatelessWidget {
  final MessagesStateStatus status;
  final String searchTerm;
  final Function onResetTap;

  const MessagesStatusInformer(
      {Key? key,
      required this.status,
      required this.searchTerm,
      required this.onResetTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == MessagesStateStatus.init) {
      return Column(
        children: [
          SizedBox(height: 40),
          Text(
            '🔎',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontSize: 64.0, fontWeight: FontWeight.w600),
          ),
          Text(
            'Find messages by entering keywords in the search',
            style:
                Theme.of(context).textTheme.headline3!.copyWith(fontSize: 14.0),
          ),
        ],
      );
    }

    if (status == MessagesStateStatus.loading) {
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
