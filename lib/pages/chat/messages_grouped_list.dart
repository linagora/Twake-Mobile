/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/messages_bloc/messsage_loaded_type.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/single_message_bloc/single_message_bloc.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/dateformatter.dart';

class MessagesGroupedList<T extends BaseChannelBloc> extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState<T>();
}

class _MessagesGroupedListState<T extends BaseChannelBloc>
    extends State<MessagesGroupedList<T>> {
  final _itemPositionListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc<T>, MessagesState>(
      builder: (context, state) {
        List<Message?>? messages = <Message>[];
        final isDirect = state.parentChannel is Direct;

        if (state is MessagesLoaded) {
          if (state.messages!.isEmpty) {
            return EmptyChatContainer(
              isDirect: isDirect,
              userName: state.parentChannel!.name,
            );
          }
          messages = state.messages;
        } else if (state is MessagesEmpty) {
          return EmptyChatContainer(
            isDirect: isDirect,
            userName: state.parentChannel!.name,
          );
        } else if (state is ErrorLoadingMessages) {
          return EmptyChatContainer(isError: true);
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
              if (state is MessagesLoaded) {
                BlocProvider.of<MessagesBloc<T>>(context).add(
                  LoadMoreMessages(
                    beforeId: state.messages!.first!.id,
                    beforeTimeStamp: state.messages!.first!.creationDate,
                  ),
                );
              }
            }
            return true;
          },
          child: Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _buildStickyGroupedListView(context, state, messages!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyGroupedListView(
      BuildContext context, MessagesState state, List<Message?> messages) {
    var lastScrollPosition = 0;
    final _groupedItemScrollController = GroupedItemScrollController();
    try {
      if (state is MessagesLoaded) {
        if (state.messageLoadedType == MessageLoadedType.loadMore) {
          lastScrollPosition = _itemPositionListener.itemPositions.value.last.index;
        } else if (state.messageLoadedType == MessageLoadedType.afterDelete) {
          lastScrollPosition = _itemPositionListener.itemPositions.value.first.index;
        } else {
          final ProfileState profileState = context.read<ProfileBloc>().state;
          if (profileState is ProfileLoaded) {
            final badge = profileState.getBadgeForChannel(state.parentChannel!.id);
            if (badge > 1) {
              Future.delayed(Duration(milliseconds: 300), () {
                _groupedItemScrollController.jumpTo(index: badge > messages.length ? messages.length - 1 : badge);
              });
            }
          }
        }
      }
    } catch (exception) {
      lastScrollPosition = 0;
    }

    return StickyGroupedListView<Message?, DateTime>(
      initialScrollIndex: lastScrollPosition,
      itemScrollController: _groupedItemScrollController,
      itemPositionsListener: _itemPositionListener,
      key: ValueKey(state is MessagesLoaded ? state.messageCount : 0),
      order: StickyGroupedListOrder.DESC,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(bottom: 12.0),
      reverse: true,
      elements: messages,
      groupBy: (Message? m) {
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(m!.creationDate!);
        return DateTime(dt.year, dt.month, dt.day);
      },
      groupComparator: (DateTime value1, DateTime value2) =>
          value1.compareTo(value2),
      itemComparator: (Message? m1, Message? m2) {
        return m1!.creationDate!.compareTo(m2!.creationDate!);
      },
      separator: SizedBox(height: 12.0),
      groupSeparatorBuilder: (Message? message) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          child: Container(
            height: 53.0,
            alignment: Alignment.center,
            child: Text(
              DateFormatter.getVerboseDate(message!.creationDate!),
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
        Message? nextMessage = Message();
        if (index > 0) {
          nextMessage = messages.reversed.toList()[index - 1];
          // print('Current message: ${message.sender} ${message.content.originalStr}');
          // print('Next message: ${nextMessage.sender} - ${nextMessage.content.originalStr}');
        }
        final shouldShowSender = nextMessage!.userId != message!.userId;

        return MessageTile<T>(
          message: message,
          shouldShowSender: shouldShowSender,
          key: ValueKey(
            message.id! +
                message.responsesCount.toString() +
                message.reactions!.map((r) => r['name']).join() +
                (message.content!.originalStr ?? ''),
          ),
        );
      },
    );
  }
}
 */
