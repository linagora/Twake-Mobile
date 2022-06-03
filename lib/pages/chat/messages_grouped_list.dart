import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/bubble_side.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:twake/widgets/common/channel_first_message.dart';
import 'package:twake/widgets/common/highlight_component.dart';
import 'package:twake/widgets/common/searchable_grouped_listview.dart';

class MessagesGroupedList extends StatefulWidget {
  final Channel parentChannel;
  const MessagesGroupedList({required this.parentChannel});

  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState();
}

class _MessagesGroupedListState extends State<MessagesGroupedList> {
  final SwipeActionController swipeController = SwipeActionController();
  final SearchableGroupChatController _controller =
      SearchableGroupChatController();

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
    return BlocListener<PinnedMessageCubit, PinnedMessageState>(
      bloc: Get.find<PinnedMessageCubit>(),
      listenWhen: (previous, _) =>
          previous.pinnedMesssageStatus == PinnedMessageStatus.selected,
      listener: (context, state) {
        int selected = state.selected;
        Message jumpMessage = state.pinnedMessageList[selected];
        if (!jumpMessage.inThread) {
          _controller.jumpMessage(messages, state.pinnedMessageList[selected]);
        } else {
          NavigatorService.instance.navigate(
            channelId: jumpMessage.channelId,
            threadId: jumpMessage.threadId,
            reloadThreads: false,
            pinnedMessage: jumpMessage,
          );
        }
      },
      child: SearchableChatView(
          searchableChatController: _controller,
          reverse: true,
          messages: messages,
          indexedItemBuilder: (_, message, index) {
            //conditions for determining the shape of the bubble sides
            final List<bool> bubbleSides = bubbleSide(messages, index, true);
            return SwipeActionCell(
                controller: swipeController,
                key: ObjectKey(messages[index]),
                performsFirstActionWithFullSwipe: true,
                fullSwipeFactor: 0.1,
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

                        await NavigatorService.instance.navigate(
                          channelId: message.channelId,
                          threadId: message.id,
                          reloadThreads: false,
                        );
                        swipeController.closeAllOpenCell();
                      },
                      color: Colors.transparent),
                ],
                child: HighlightComponent(
                  highlightColor: Theme.of(context).highlightColor,
                  component: (index == messages.length - 1 && endOfHistory)
                      ? ChannelFirstMessage(
                          channel: widget.parentChannel,
                          icon: message.picture ?? "")
                      : MessageTile<ChannelMessagesCubit>(
                          message: message,
                          upBubbleSide: bubbleSides[0],
                          downBubbleSide: bubbleSides[1],
                          key: ValueKey(message.hash),
                          channel: widget.parentChannel,
                        ),
                  highlightWhen: _controller.highlightMessage != null &&
                      _controller.highlightMessage == message,
                ));
          }),
    );
  }
}
