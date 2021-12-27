import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/bubble_side.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:twake/widgets/common/channel_first_message.dart';

class MessagesGroupedList extends StatefulWidget {
  final Channel parentChannel;
  const MessagesGroupedList({required this.parentChannel});

  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState();
}

class _MessagesGroupedListState extends State<MessagesGroupedList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelMessagesCubit, MessagesState>(
      bloc: Get.find<ChannelMessagesCubit>(),
      builder: (context, state) {
        List<Message> messages = <Message>[];
        bool endOfHistory = false;
        if (state is NoMessagesFound) {
          return EmptyChatContainer(
            isDirect: widget.parentChannel.isDirect,
            userName: widget.parentChannel.name,
          );
        } else if (state is MessagesLoadSuccess) {
          if (state.messages.isEmpty) {
            return MessagesLoadingAnimation();
          }
          endOfHistory = state.endOfHistory;
          messages = state.messages;
        } else {
          return MessagesLoadingAnimation();
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              Get.find<ChannelMessagesCubit>().fetchBefore(
                channelId: Globals.instance.channelId!,
              );
            }
            return true;
          },
          child: Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child:
                  _buildStickyGroupedListView(context, messages, endOfHistory),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyGroupedListView(
      BuildContext context, List<Message> messages, bool endOfHistory) {
    return GroupedListView<Message, DateTime>(
      // addAutomaticKeepAlives: true,
      key: PageStorageKey<String>('uniqueKey'),
      order: GroupedListOrder.DESC,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(bottom: 12.0),
      reverse: true,
      elements: messages,
      groupBy: (Message m) {
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(m.createdAt);
        return DateTime(dt.year, dt.month, dt.day);
      },
      groupComparator: (DateTime value1, DateTime value2) =>
          value1.compareTo(value2),
      itemComparator: (Message m1, Message m2) {
        if (m1.createdAt.compareTo(m2.createdAt) == -1) {
          return m1.createdAt.compareTo(m2.createdAt);
        } else {
          return m2.createdAt.compareTo(m1.createdAt);
        }
      },
      separator: SizedBox(height: 1.0),
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
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      indexedItemBuilder: (_, message, index) {
        //conditions for determining the shape of the bubble sides
        final List<bool> bubbleSides = bubbleSide(messages, index, true);
        return SwipeActionCell(
          key: ObjectKey(messages[index]),
          performsFirstActionWithFullSwipe: true,
          fullSwipeFactor: 0.15,
          trailingActions: <SwipeAction>[
            SwipeAction(
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        'assets/images/reply.png',
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                onTap: (CompletionHandler handler) async {
                  Get.find<ThreadMessagesCubit>().reset();

                  Get.find<ThreadMessagesCubit>().swipeReply(message);

                  setState(() {});
                },
                color: Colors.transparent),
          ],
          child: (index == messages.length - 1 && endOfHistory)
              ? ChannelFirstMessage(
                  channel: widget.parentChannel, icon: message.picture ?? "")
              : MessageTile<ChannelMessagesCubit>(
                  message: message,
                  upBubbleSide: bubbleSides[0],
                  downBubbleSide: bubbleSides[1],
                  key: ValueKey(message.hash),
                  channel: widget.parentChannel,
                ),
        );
      },
    );
  }
}
