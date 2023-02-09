import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/blocs/quote_message_cubit/quote_message_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/animated_bounce.dart';
import 'package:twake/widgets/common/channel_first_message.dart';
import 'package:twake/widgets/common/highlight_component.dart';

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
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
        onNotification: (scrollInfo) {
          // when user scroll out of viewport
          if (scrollInfo.metrics.atEdge) {
            final isBottom = scrollInfo.metrics.pixels == 0;
            if (isBottom) {
              Get.find<ChannelMessagesCubit>().fetchAfter(
                channelId: Globals.instance.channelId!,
                isDirect: widget.parentChannel.isDirect,
              );
            } else {
              Get.find<ChannelMessagesCubit>().fetchBefore(
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

  _ChatView({
    required this.parentChannel,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  int highlightMessageIndex = -11;
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  final SwipeActionController _swipeActionController = SwipeActionController();

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

        return _stickyGroupedListView(state.messages);
      },
    );
  }

  Widget _stickyGroupedListView(List<Message> messages) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PinnedMessageCubit, PinnedMessageState>(
          bloc: Get.find<PinnedMessageCubit>(),
          listener: (context, state) {
            if (state.pinnedMesssageStatus == PinnedMessageStatus.jumpToPin) {
              highlightMessageIndex = state.selectedChatMessageIndex;
              itemScrollController.scrollTo(
                  index: state.selectedChatMessageIndex - 1,
                  duration: Duration(seconds: 1));
              Get.find<PinnedMessageCubit>().emitFinishedState();
            }
          },
        ),
        BlocListener<QuoteMessageCubit, QuoteMessageState>(
          bloc: Get.find<QuoteMessageCubit>(),
          listener: (context, state) {
            if (state.quoteMessageStatus == QuoteMessageStatus.jumpToQuote) {
              highlightMessageIndex = state.quoteMessageIndex;
              itemScrollController.scrollTo(
                  index: state.quoteMessageIndex - 1,
                  duration: Duration(seconds: 1));
              Get.find<QuoteMessageCubit>().emitQuoteDoneState();
            }
          },
        ),
      ],
      child: StickyGroupedListView<Message, DateTime>(
        initialScrollIndex: 0,
        initialAlignment: 0,
        elements: messages,
        reverse: true,
        floatingHeader: false,
        itemPositionsListener: _itemPositionsListener,
        groupSeparatorBuilder: (Message msg) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus!.unfocus();
            },
            child: Container(
              height: 53.0,
              alignment: Alignment.center,
              child: Text(
                DateFormatter.getVerboseDate(msg.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        groupBy: (Message m) {
          final DateTime dt = DateTime.fromMillisecondsSinceEpoch(m.createdAt);
          return DateTime(dt.year, dt.month, dt.day);
        },
        groupComparator: (DateTime value1, DateTime value2) =>
            value2.compareTo(value1),
        itemComparator: (Message m1, Message m2) =>
            m2.createdAt.compareTo(m1.createdAt),
        separator: SizedBox(height: 1.0),
        itemScrollController: itemScrollController,
        stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indexedItemBuilder: (itemContext, message, index) {
          return SwipeActionCell(
            controller: _swipeActionController,
            key: ObjectKey(messages[index]),
            fullSwipeFactor: 0.15,
            trailingActions: <SwipeAction>[
              SwipeAction(
                  performsFirstActionWithFullSwipe: true,
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        child: Image.asset(
                          'assets/images/reply.png',
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  onTap: (CompletionHandler handler) async {
                    widget.parentChannel.isDirect
                        ? Get.find<QuoteMessageCubit>().addQuoteMessage(message)
                        : await NavigatorService.instance.navigateToThread(
                            channelId: message.channelId,
                            threadId: message.id,
                          );
                    _swipeActionController.closeAllOpenCell();
                  },
                  color: Colors.transparent),
            ],
            child: message.id == endOfHistory
                ? ChannelFirstMessage(
                    channel: widget.parentChannel,
                  )
                : Bounce(
                    onLongPress: () {
                      Get.find<MessageAnimationCubit>().startAnimation(
                        messagesListContext: context,
                        longPressMessage: message,
                        longPressIndex:
                            index * 2, // because the replied message
                        itemPositionsListener: _itemPositionsListener,
                      );
                    },
                    duration: Duration(milliseconds: 200),
                    child: index == highlightMessageIndex
                        ? HighlightComponent(
                            component: MessageTile<ChannelMessagesCubit>(
                              message: message,
                              isDirect: widget.parentChannel.isDirect,
                              key: ValueKey(message.hash),
                              isSenderHidden: false,
                            ),
                            highlightWhen: true,
                            highlightColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          )
                        : MessageTile<ChannelMessagesCubit>(
                            message: message,
                            isDirect: widget.parentChannel.isDirect,
                            key: ValueKey(message.hash),
                            isSenderHidden: false,
                          ),
                  ),
          );
        },
      ),
    );
  }
}
