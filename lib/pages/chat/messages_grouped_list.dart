import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
// import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/dateformatter.dart';

class MessagesGroupedList extends StatefulWidget {
  final Channel parentChannel;

  const MessagesGroupedList({required this.parentChannel});

  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState();
}

class _MessagesGroupedListState extends State<MessagesGroupedList> {
  // final _itemPositionListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelMessagesCubit, MessagesState>(
      bloc: Get.find<ChannelMessagesCubit>(),
      builder: (context, state) {
        List<Message> messages = <Message>[];

        if (state is MessagesLoadSuccess) {
          if (state.messages.isEmpty) {
            return EmptyChatContainer(
              isDirect: widget.parentChannel.isDirect,
              userName: widget.parentChannel.name,
            );
          }
          messages = state.messages;
        } else if (state is MessagesBeforeLoadInProgress) {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              Get.find<ChannelMessagesCubit>().fetchBefore();
            }
            return true;
          },
          child: Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _buildStickyGroupedListView(context, messages),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyGroupedListView(
      BuildContext context,
      List<Message> messages,
      ) {
    // final _groupedItemScrollController = GroupedItemScrollController(); // TODO: reimplement scroll to necessary position

    return GroupedListView<Message, DateTime>(
      key: ValueKey(messages.length),
      order: GroupedListOrder.DESC,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(bottom: 12.0),
      reverse: true,
      elements: messages,
      groupBy: (Message m) {
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(m.creationDate);
        return DateTime(dt.year, dt.month, dt.day);
      },
      groupComparator: (DateTime value1, DateTime value2) =>
          value1.compareTo(value2),
      itemComparator: (Message m1, Message m2) {
        return m1.creationDate.compareTo(m2.creationDate);
      },
      separator: SizedBox(height: 3.0),
      groupSeparatorBuilder: (DateTime dt) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          child: Container(
            height: 53.0,
            alignment: Alignment.center,
            child: Text(
              DateFormatter.getVerboseDate(dt.millisecondsSinceEpoch),
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
                color: Color(0xff8f9498),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      indexedItemBuilder: (_, message, index) {
        return MessageTile<ChannelMessagesCubit>(
          message: message,
          key: ValueKey(message.hash),
        );
      },
    );
  }
}
