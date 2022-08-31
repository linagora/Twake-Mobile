import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/jumpable_pinned_messages.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/pages/chat/unread_messages_widget.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:twake/widgets/common/channel_first_message.dart';
import 'package:twake/widgets/common/highlight_component.dart';
import 'package:twake/widgets/common/searchable_grouped_listview.dart';

class MessagesGroupedList extends StatefulWidget {
  final Channel parentChannel;
  const MessagesGroupedList({
    required this.parentChannel,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState();
}

class _MessagesGroupedListState extends State<MessagesGroupedList> {
  bool isTop = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          // when user scroll out of viewport
          if (scrollInfo.metrics.atEdge) {
            isTop = scrollInfo.metrics.pixels == 0;
            if (isTop) {
              Get.find<ChannelMessagesCubit>().fetchBefore(
                channelId: Globals.instance.channelId!,
                isDirect: widget.parentChannel.isDirect,
              );
            } else {
              Get.find<ChannelMessagesCubit>().fetchAfter(
                channelId: Globals.instance.channelId!,
                isDirect: widget.parentChannel.isDirect,
              );
            }
          }
          return true;
        },
        child: Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _ChatView(
              parentChannel: widget.parentChannel,
            ),
          ),
        ));
  }
}

class _ChatView extends StatefulWidget {
  final Channel parentChannel;
  final int initialScrollIndex;

  _ChatView({
    required this.parentChannel,
    this.initialScrollIndex = 0,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final SearchableGroupChatController _jumpController =
      SearchableGroupChatController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final SwipeActionController _swipeActionController = SwipeActionController();

  // Chatview will start with index of startMessage, if not it's will be latest message
  Message? _startMessage;
  Message? latestMessage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelMessagesCubit, MessagesState>(
      bloc: Get.find<ChannelMessagesCubit>(),
      builder: (context, state) {
        if (state is NoMessagesFound) {
          return EmptyChatContainer(
            isDirect: widget.parentChannel.isDirect,
            userName: widget.parentChannel.name,
          );
        }

        // if load messages is not success or success but empty
        if (state is! MessagesLoadSuccess || state.messages.isEmpty) {
          return MessagesLoadingAnimation();
        }

        if (state is MessageLatestSuccess) {
          latestMessage = state.latestMessage;
        }

        if (state is MessagesAroundPinnedLoadSuccess) {
          _startMessage = state.pinnedMessage;
        }

        return JumpablePinnedMessages(
            child: UnreadMessagesWidget(
              messages: state.messages,
              startMessage: _startMessage,
              itemPositionsListener: _itemPositionsListener,
              jumpController: _jumpController,
              indexedItemBuilder:
                  (context, Message message, int index, bool isSenderHidden) {
                return _buildSwipeActionCell(state.messages, message, index,
                    state.endOfHistory, isSenderHidden);
              },
            ),
            messages: state.messages,
            jumpToMessage: ((messages, jumpedMessage) {
              _jumpController.scrollToMessage(messages, jumpedMessage);
            }),
            isDirect: widget.parentChannel.isDirect);
      },
    );
  }

  Widget _buildSwipeActionCell(List<Message> messages, Message message,
      int index, bool endOfHistory, bool isSenderHidden) {
    return SwipeActionCell(
        controller: _swipeActionController,
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
                await NavigatorService.instance.navigate(
                  channelId: message.channelId,
                  threadId: message.id,
                  reloadThreads: false,
                );
                _swipeActionController.closeAllOpenCell();
              },
              color: Colors.transparent),
        ],
        child: HighlightComponent(
          highlightColor: Theme.of(context).highlightColor,
          component: (index == messages.length - 1 && endOfHistory)
              ? ChannelFirstMessage(
                  channel: widget.parentChannel, icon: message.picture ?? "")
              : MessageTile<ChannelMessagesCubit>(
                  message: message,
                  isDirect: widget.parentChannel.isDirect,
                  key: ValueKey(message.hash),
                  isSenderHidden: isSenderHidden,
                ),
          highlightWhen: _jumpController.highlightMessage != null &&
              _jumpController.highlightMessage == message &&
              latestMessage ==
                  null, // don't need to highlight when have unread messages
        ));
  }
}
