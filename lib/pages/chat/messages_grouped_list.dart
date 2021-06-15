import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_state.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/empty_chat_container.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/dateformatter.dart';

class MessagesGroupedList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MessagesGroupedListState();
}

class _MessagesGroupedListState
    extends State<MessagesGroupedList> {
  final _itemPositionListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelMessagesCubit, MessagesState>(
      bloc: Get.find<ChannelMessagesCubit>(),
      builder: (context, state) {
        List<Message> messages = <Message>[];
        final isDirect = true; //pass it from chat  state.parentChannel is Direct;

        if (state is MessagesLoadSuccess) {
          if (state.messages.isEmpty) {
            return EmptyChatContainer(
              isDirect: isDirect,
              userName: 'Test'// pass it from chat 
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
              child: _buildStickyGroupedListView(context, state, messages),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyGroupedListView(
      BuildContext context, MessagesState state, List<Message> messages) {
    var lastScrollPosition = 0;
    final _groupedItemScrollController = GroupedItemScrollController();
    try {
      if (state is MessagesLoadSuccess) {/*
        if (state == MessagesBeforeLoadInProgress ) {
          lastScrollPosition =
              _itemPositionListener.itemPositions.value.last.index;
        }  else if (state == MessageLoadedType.afterDelete) {
          lastScrollPosition =
              _itemPositionListener.itemPositions.value.first.index;
        } else {
          final ProfileState profileState = context.read<ProfileBloc>().state;
          if (profileState is ProfileLoaded) {
            final badge =
                profileState.getBadgeForChannel(state.parentChannel!.id);
            if (badge > 1) {
              Future.delayed(Duration(milliseconds: 300), () {
                _groupedItemScrollController.jumpTo(
                    index:
                        badge > messages.length ? messages.length - 1 : badge);
              });
            }
          }
        }*/
      } 
    } catch (exception) {
      lastScrollPosition = 0;
    }

    return StickyGroupedListView<Message, DateTime>(
      initialScrollIndex: lastScrollPosition,
      itemScrollController: _groupedItemScrollController,
      itemPositionsListener: _itemPositionListener,
      key: ValueKey(state is MessagesLoadSuccess ? state.messages.length : 0),
      order: StickyGroupedListOrder.DESC,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(bottom: 12.0),
      reverse: true,
      elements: messages,
      groupBy: (Message? m) {
        final DateTime dt =
            DateTime.fromMillisecondsSinceEpoch(m!.creationDate);
        return DateTime(dt.year, dt.month, dt.day);
      },
      groupComparator: (DateTime value1, DateTime value2) =>
          value1.compareTo(value2),
      itemComparator: (Message? m1, Message? m2) {
        return m1!.creationDate.compareTo(m2!.creationDate);
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
              DateFormatter.getVerboseDate(message!.creationDate),
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
     
        final shouldShowSender = messages.reversed.toList()[index - 1].userId != message.userId;

        return MessageTile(
          message: message,
          shouldShowSender: shouldShowSender,
          key: ValueKey(
            message.id +
                message.responsesCount.toString() +
               // message.reactions.map((r) => r['name']).join() +
                (message.content.originalStr ?? ''),
          ),
        );
      },
    );
  }
}
