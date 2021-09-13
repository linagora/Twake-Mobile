import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/bubble_side.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:twake/widgets/common/channel_first_message.dart';
import 'package:twake/widgets/common/reaction.dart';

class MessagesGroupedList extends StatefulWidget {
  final Channel parentChannel;
  final bool isThread;
  const MessagesGroupedList(
      {required this.parentChannel, required this.isThread});

  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState();
}

class _MessagesGroupedListState extends State<MessagesGroupedList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isThread) {
      return BlocBuilder<ThreadMessagesCubit, MessagesState>(
        bloc: Get.find<ThreadMessagesCubit>(),
        builder: (ctx, state) {
          if (state is MessagesLoadSuccess) {
            final messages = state.messages;
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                constraints:
                    BoxConstraints(maxHeight: 70 * Dim.heightMultiplier),
                child: Column(
                  children: [
                    MessageColumn(
                      message: messages.first,
                      parentChannel: widget.parentChannel,
                    ),
                    Expanded(
                      child:
                          _buildStickyGroupedListView(context, messages, false),
                    ),
                  ],
                ),
              ),
            );
          } else
            return Container();
        },
      );
    } else {
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
                child: _buildStickyGroupedListView(
                    context, messages, endOfHistory),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildStickyGroupedListView(
      BuildContext context, List<Message> messages, bool endOfHistory) {
    return GroupedListView<Message, DateTime>(
      // addAutomaticKeepAlives: true,
      key: PageStorageKey<String>('uniqueKey'),
      order: widget.isThread ? GroupedListOrder.ASC : GroupedListOrder.DESC,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(bottom: 12.0),
      reverse: widget.isThread ? false : true,
      elements: messages,
      groupBy: (Message m) {
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(m.createdAt);
        return DateTime(dt.year, dt.month, dt.day);
      },
      groupComparator: (DateTime value1, DateTime value2) =>
          value1.compareTo(value2),
      itemComparator: (Message m1, Message m2) {
        return m1.createdAt.compareTo(m2.createdAt);
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
        // conditions for determining the shape of the bubble sides
        final List<Message> reversedLMessages = List.from(messages.reversed);
        final List<bool> bubbleSidesThread =
            bubbleSide(reversedLMessages, index);
        if (index == 0 && widget.isThread) {
          return SizedBox.shrink();
        } else {
          //conditions for determining the shape of the bubble sides
          final List<bool> bubbleSides = bubbleSide(messages, index);
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
                    upBubbleSide: index == 1 && widget.isThread
                        ? true
                        : widget.isThread
                            ? bubbleSidesThread[1]
                            : bubbleSides[0],
                    downBubbleSide:
                        widget.isThread ? bubbleSidesThread[0] : bubbleSides[1],
                    key: ValueKey(message.hash),
                    channel: widget.parentChannel,
                  ),
          );
        }
      },
    );
  }
}

class MessageColumn extends StatelessWidget {
  final Message message;
  final Channel parentChannel;

  const MessageColumn({required this.message, required this.parentChannel});

  build(ctx) {
    final state = Get.find<ThreadMessagesCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<ThreadMessagesCubit>(
            channel: parentChannel,
            downBubbleSide: true,
            upBubbleSide: true,
            message: message,
            hideReaction: true,
            hideShowReplies: true,
            isThread: true,
            key: ValueKey(message.hash),
          ),
        ),
        if (state is MessagesLoadSuccess)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 15,
              ),
              Wrap(
                runSpacing: Dim.heightMultiplier,
                crossAxisAlignment: WrapCrossAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  ...message.reactions.map((r) {
                    return Reaction(
                      message: message,
                      reaction: r,
                      isFirstInThread: true,
                    );
                  }),
                ],
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: state.messages.length - 1 > 1
                    ? Text(
                        '${state.messages.length - 1}' + ' replies ',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF818C99),
                        ),
                      )
                    : state.messages.length - 1 == 1
                        ? Text(
                            '${state.messages.length - 1}' + ' reply ',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF818C99),
                            ),
                          )
                        : Text(
                            ' there are no replies yet ',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF818C99),
                            ),
                          ),
              ),
            ],
          ),
        SizedBox(
          height: 8.0,
        ),
        Divider(
          thickness: 5.0,
          height: 2.0,
          color: Color(0xFFF6F6F6),
        ),
        SizedBox(
          height: 12.0,
        ),
      ],
    );
  }
}
