import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/message/message_tile.dart';

class MessagesGroupedList<T extends BaseChannelBloc> extends StatefulWidget {
  @override
  _MessagesGroupedListState<T> createState() => _MessagesGroupedListState<T>();
}

class _MessagesGroupedListState<T extends BaseChannelBloc>
    extends State<MessagesGroupedList<T>> {

  final ValueNotifier<double> _scrollViewPaddingNotifier = ValueNotifier(0);
  GroupedItemScrollController _groupedItemScrollController;
  List<Message> _messages = <Message>[];

  @override
  void initState() {
    super.initState();
    // _groupedItemScrollController = GroupedItemScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_groupedItemScrollController != null) {
    //     _groupedItemScrollController.jumpTo(index: 0);
    //   }
    //   _updateScrollViewPadding();
    // });
  }

  Widget buildMessagesList(context, MessagesState state) {
    if (state is MessagesLoaded) {
      _messages = state.messages; //.reversed.toList();

      return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: ValueListenableBuilder<double>(
            valueListenable: _scrollViewPaddingNotifier,
            builder: (BuildContext context, double paddingBottom, Widget child) {
            return StickyGroupedListView<Message, DateTime>(
              itemScrollController: _groupedItemScrollController,
              order: StickyGroupedListOrder.DESC,
              stickyHeaderBackgroundColor:
                  Theme.of(context).scaffoldBackgroundColor,
              reverse: true,
              initialAlignment: 1.0,
              initialScrollIndex: _messages.length - 1,
              elements: _messages,
              groupBy: (Message m) {
                final DateTime dt =
                    DateTime.fromMillisecondsSinceEpoch(m.creationDate * 1000);
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
                                DateFormatter.getVerboseDate(
                                    message.creationDate),
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
              indexedItemBuilder: (_, Message message, int i) {
                return MessageTile<T>(
                  message: message,
                  key: ValueKey(
                    message.id + message.responsesCount.toString(),
                  ),
                );
              },
            );
          },
        ),
      );
    } else if (state is MessagesEmpty)
      return Center(
        child: Text(
          state is ErrorLoadingMessages
              ? 'Couldn\'t load messages'
              : 'No messages yet',
        ),
      );
    else
      return Center(
        child: CircularProgressIndicator(),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc<T>, MessagesState>(builder: (ctx, state) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // print(scrollInfo.metrics.maxScrollExtent);
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
            onTap: () {
              FocusManager.instance.primaryFocus.unfocus();
            },
            child: buildMessagesList(context, state),
          ),
        ),
      );
    });
  }

  void _updateScrollViewPadding() {
    print('Scroll View Padding Notifier Value: ${_scrollViewPaddingNotifier.value}');
    // final height = _textFieldKey.currentContext.size.height;
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   _scrollViewPaddingNotifier.value = height;
    // });
  }
}
