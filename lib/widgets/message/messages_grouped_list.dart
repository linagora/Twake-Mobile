import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/message/message_tile.dart';

class MessagesGroupedList<T extends BaseChannelBloc> extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState<T>();
}

class _MessagesGroupedListState<T extends BaseChannelBloc>
    extends State<MessagesGroupedList<T>> {
  final _itemPositionListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc<T>, MessagesState>(builder: (ctx, state) {
      var messages = <Message>[];

      if (state is MessagesLoaded) {
        messages = state.messages;
      } else if (state is MessagesEmpty) {
        return Flexible(
          child: Column(
            children: [
              EmptyChatContainer(),
              Spacer(),
            ],
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
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (state is MessagesLoaded) {
              BlocProvider.of<MessagesBloc<T>>(context).add(
                LoadMoreMessages(
                  beforeId: state.messages.first.id,
                  beforeTimeStamp: state.messages.first.creationDate,
                ),
              );
            }
          }
          return true;
        },
        child: Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _buildStickyGroupedListView(context, state, messages),
          ),
        ),
      );
    });
  }

  Widget _buildStickyGroupedListView(
      BuildContext context, MessagesState state, List<Message> messages) {
    var lastScrollPosition;
    try {
      lastScrollPosition = _itemPositionListener.itemPositions.value.last.index;
    } catch (exception) {
      lastScrollPosition = 0;
    }

    return StickyGroupedListView<Message, DateTime>(
      initialScrollIndex: lastScrollPosition,
      itemPositionsListener: _itemPositionListener,
      key: ValueKey(state is MessagesLoaded ? state.messageCount : 0),
      order: StickyGroupedListOrder.DESC,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      separator: SizedBox(height: Dim.hm2),
      groupSeparatorBuilder: (Message message) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus.unfocus();
          },
          child: Container(
            height: Dim.hm3,
            margin: EdgeInsets.symmetric(vertical: Dim.hm2),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Divider(
                    thickness: 0.0,
                  ),
                ),
                Align(
                  // alignment: Alignment.center,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: Dim.widthPercent(30),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        DateFormatter.getVerboseDate(message.creationDate),
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff92929C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemBuilder: (_, Message message) {
        return MessageTile<T>(
          message: message,
          key: ValueKey(
            message.id +
                message.responsesCount.toString() +
                message.reactions.keys.join() +
                (message.content.originalStr ?? ''),
          ),
        );
      },
    );
  }
}
