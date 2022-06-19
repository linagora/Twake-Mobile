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
  GlobalKey<_ChatViewState> _chatViewKey = GlobalKey();
  bool isTop = false;
  Message? startMessage;

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
        return NotificationListener<ScrollEndNotification>(
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
              child: _buildStickyGroupedListView(context, messages,
                  endOfHistory, widget.parentChannel.isDirect),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyGroupedListView(BuildContext context,
      List<Message> messages, bool endOfHistory, bool isDirect) {
    return BlocListener<PinnedMessageCubit, PinnedMessageState>(
        bloc: Get.find<PinnedMessageCubit>(),
        listenWhen: (previous, _) =>
            previous.pinnedMesssageStatus == PinnedMessageStatus.selected,
        listener: (context, state) async {
          int selected = state.selected;
          Message jumpMessage = state.pinnedMessageList[selected];
          if (!jumpMessage.inThread) {
            if (messages.contains(jumpMessage)) {
              _chatViewKey.currentState!._controller
                  .jumpMessage(messages, jumpMessage);
            } else {
              // get messages around selectec pinned message
              List<Message> messages = await Get.find<PinnedMessageCubit>()
                  .getMessagesAroundSelectedMessage(
                      message: jumpMessage, isDirect: isDirect);

              // update the current messages in chat
              Get.find<ChannelMessagesCubit>()
                  .fetchMessagesAroundPinned(messages: messages);

              startMessage = jumpMessage;
            }
          } else {
            NavigatorService.instance.navigate(
              channelId: jumpMessage.channelId,
              threadId: jumpMessage.threadId,
              reloadThreads: false,
              pinnedMessage: jumpMessage,
            );
          }
        },
        child: _ChatView(
          key: _chatViewKey,
          parentChannel: widget.parentChannel,
          messages: messages,
          endOfHistory: endOfHistory,
          startMessage: startMessage,
        ));
  }
}

class _ChatView extends StatefulWidget {
  final List<Message> messages;
  final bool endOfHistory;
  final Channel parentChannel;
  final int initialScrollIndex;
  // Chatview will start with index of startMessage, if not it's will be latest message
  final Message? startMessage;

  _ChatView({
    Key? key,
    required this.messages,
    required this.endOfHistory,
    required this.parentChannel,
    this.initialScrollIndex = 0,
    this.startMessage,
  }) : super(key: key);
  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late List<Message> _messages;
  final SwipeActionController swipeController = SwipeActionController();
  final SearchableGroupChatController _controller =
      SearchableGroupChatController();
  Message? _startMessage;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
  }

  @override
  void didUpdateWidget(covariant _ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startMessage != this.widget.startMessage) {
      _startMessage = widget.startMessage;
    }

    if (oldWidget.messages != this.widget.messages) {
      _messages = widget.messages;
    }
    print(_startMessage == null ? 0 : _messages.indexOf(_startMessage!));
  }

  @override
  Widget build(BuildContext context) {
    return SearchableChatView(
        initialScrollIndex:
            _startMessage == null ? 0 : _messages.indexOf(_startMessage!),
        searchableChatController: _controller,
        reverse: true,
        messages: _messages,
        indexedItemBuilder: (_, message, index) {
          //conditions for determining the shape of the bubble sides
          final List<bool> bubbleSides = bubbleSide(_messages, index, true);
          return SwipeActionCell(
              controller: swipeController,
              key: ObjectKey(_messages[index]),
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
                component:
                    (index == _messages.length - 1 && widget.endOfHistory)
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
        });
  }
}
