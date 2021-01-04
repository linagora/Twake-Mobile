import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/message/message_tile.dart';

class MessagesGrouppedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(builder: (ctx, state) {
      print('REBUILDING MESSAGES PAGE');
      return state is MessagesLoaded
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  BlocProvider.of<MessagesBloc>(context).add(LoadMoreMessages(
                    beforeId: state.messages.last.id,
                    beforeTimeStamp: state.messages.last.creationDate,
                  ));
                }
                return true;
              },
              child: Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus.unfocus();
                  },
                  child: StickyGroupedListView<Message, DateTime>(
                    reverse: true,
                    elements: state.messages,
                    order: StickyGroupedListOrder.ASC,
                    groupBy: (Message m) {
                      final DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                          m.creationDate * 1000);
                      return DateTime(dt.year, dt.month, dt.day);
                    },
                    groupComparator: (DateTime value1, DateTime value2) =>
                        value2.compareTo(value1),
                    itemComparator: (Message m1, Message m2) {
                      return m2.creationDate.compareTo(m1.creationDate);
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
                    addAutomaticKeepAlives: false,
                    itemBuilder: (_, Message message) {
                      if (!message.hidden) {
                        return BlocProvider<SingleMessageBloc>(
                          create: (_) => SingleMessageBloc(message),
                          child: MessageTile(),
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: Dim.hm3),
                            child: Text(
                              'Message deleted',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ))
          : Center(child: CircularProgressIndicator());
    });
  }
}
