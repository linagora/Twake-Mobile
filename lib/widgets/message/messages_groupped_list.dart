import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/message/message_tile.dart';

class MessagesGrouppedList<T extends BaseChannelBloc> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc<T>, MessagesState>(builder: (ctx, state) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (state is MessagesLoaded)
              BlocProvider.of<MessagesBloc<T>>(context).add(LoadMoreMessages(
                beforeId: state.messages.first.id,
                beforeTimeStamp: state.messages.first.creationDate,
              ));
          }
          return true;
        },
        child: Expanded(
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus.unfocus();
            },
            child: state is MessagesLoaded
                ? StickyGroupedListView<Message, DateTime>(
                    order: StickyGroupedListOrder.DESC,
                    reverse: true,
                    elements: state.messages,
                    groupBy: (Message m) {
                      final DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                          m.creationDate * 1000);
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
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: Dim.widthPercent(30),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text(
                                        DateFormatter.getVerboseDate(
                                            message.creationDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                    // addAutomaticKeepAlives: false,
                    indexedItemBuilder: (_, Message message, int i) {
                      return !message.hidden
                          ? MessageTile<T>(
                              message: message,
                              key: ValueKey(message.id),
                            )
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: Dim.hm3),
                                child: Text(
                                  'Message deleted',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            );
                    })
                : Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    });
  }
}
