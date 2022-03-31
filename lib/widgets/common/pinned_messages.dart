import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/circular_reveal_clipper.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/utilities.dart';

class PinnedMessages extends StatefulWidget {
  const PinnedMessages({Key? key}) : super(key: key);

  @override
  State<PinnedMessages> createState() => _PinnedMessagesState();
}

class _PinnedMessagesState extends State<PinnedMessages> {
  @override
  Widget build(BuildContext context) {
    final int pinnedMessages =
        Get.find<PinnedMessageCubit>().state.pinnedMessageList.length;

    final Channel channel = Get.arguments;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 34,
                ),
                Spacer(),
                Text("Pinned messages",
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
                Spacer(),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      // CupertinoIcons.clear,
                      Icons.clear,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  onTap: () => Get.back(),
                )
              ],
            ),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
            ),
            BlocBuilder<PinnedMessageCubit, PinnedMessageState>(
              bloc: Get.find<PinnedMessageCubit>(),
              builder: (context, state) {
                if (state.pinnedMesssageStatus ==
                    PinnedMessageStatus.finished) {
                  return Expanded(
                    child: GroupedListView<Message, DateTime>(
                      // addAutomaticKeepAlives: true,
                      key: PageStorageKey<String>('uniqueKey'),
                      order: GroupedListOrder.DESC,
                      stickyHeaderBackgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      padding: EdgeInsets.only(bottom: 12.0),
                      reverse: false,
                      elements: state.pinnedMessageList,
                      groupBy: (Message m) {
                        final DateTime dt =
                            DateTime.fromMillisecondsSinceEpoch(m.createdAt);
                        return DateTime(dt.year, dt.month, dt.day);
                      },
                      groupComparator: (DateTime value1, DateTime value2) =>
                          value1.compareTo(value2),
                      itemComparator: (Message m1, Message m2) {
                        if (m1.createdAt.compareTo(m2.createdAt) == -1) {
                          return m1.createdAt.compareTo(m2.createdAt);
                        } else {
                          return m2.createdAt.compareTo(m1.createdAt);
                        }
                      },
                      separator: SizedBox(height: 1.0),
                      groupSeparatorBuilder: (DateTime dt) {
                        return GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus!.unfocus();
                          },
                          child: Container(
                            height: 53.0,
                            alignment: Alignment.center,
                            child: Text(
                              DateFormatter.getVerboseDate(
                                  dt.millisecondsSinceEpoch),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                      indexedItemBuilder: (_, message, index) {
                        return MessageTile<ChannelMessagesCubit>(
                          isPinned: true,
                          message: message,
                          upBubbleSide: true,
                          downBubbleSide: true,
                          key: ValueKey(message.hash),
                          channel: channel,
                        );
                      },
                    ),
                  );
                } else if (state.pinnedMesssageStatus ==
                    PinnedMessageStatus.init) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Text("There are no pinned messages yet",
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(fontWeight: FontWeight.normal)),
                    ],
                  );
                } else
                  return Expanded(child: Container());
              },
            ),
            BlocBuilder<PinnedMessageCubit, PinnedMessageState>(
              bloc: Get.find<PinnedMessageCubit>(),
              builder: (context, state) {
                if (state.pinnedMesssageStatus ==
                        PinnedMessageStatus.finished ||
                    state.pinnedMesssageStatus == PinnedMessageStatus.loading) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Container(
                      width: Dim.widthPercent(90),
                      height: 60,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        onPressed: () async {
                          final res = await Get.find<PinnedMessageCubit>()
                              .unpinAllMessages();

                          if (res) {
                            Get.back();
                            Utilities.showSimpleSnackBar(
                                context: context,
                                message: "$pinnedMessages messages unpinned",
                                duration: Duration(seconds: 2));
                          } else {
                            Utilities.showSimpleSnackBar(
                                context: context,
                                message: "Sorry, something went wrong");
                          }
                        },
                        child:
                            BlocBuilder<PinnedMessageCubit, PinnedMessageState>(
                          bloc: Get.find<PinnedMessageCubit>(),
                          builder: (context, state) {
                            if (state.pinnedMesssageStatus ==
                                PinnedMessageStatus.finished) {
                              return Center(
                                child: Text(
                                  'Unpin all messages',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400),
                                ),
                              );
                            } else
                              return Center(
                                  child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.surface,
                              ));
                          },
                        ),
                      ),
                    ),
                  );
                } else
                  return SizedBox.shrink();
              },
            )
          ],
        ),
      ),
    );
  }
}
