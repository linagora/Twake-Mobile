import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/utilities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PinnedMessages extends StatefulWidget {
  const PinnedMessages({Key? key}) : super(key: key);

  @override
  State<PinnedMessages> createState() => _PinnedMessagesState();
}

class _PinnedMessagesState extends State<PinnedMessages> {
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();

  @override
  void initState() {
    Get.find<PinnedMessageCubit>().unpinAllReset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int pinnedMessages =
        Get.find<PinnedMessageCubit>().state.pinnedMessageList.length;

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
                Text(AppLocalizations.of(context)!.pinnedMessages,
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
            BlocBuilder<PinnedMessageCubit, PinnedMessageState>(
              bloc: Get.find<PinnedMessageCubit>(),
              builder: (context, state) {
                if (state.pinnedMesssageStatus ==
                    PinnedMessageStatus.finished) {
                  return Flexible(
                    child: StickyGroupedListView<Message, DateTime>(
                      elements: state.pinnedMessageList,
                      reverse: false,
                      floatingHeader: false,
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
                                  .headline2!
                                  .copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                      groupBy: (Message m) {
                        final DateTime dt =
                            DateTime.fromMillisecondsSinceEpoch(m.createdAt);
                        return DateTime(dt.year, dt.month, dt.day);
                      },
                      groupComparator: (DateTime value1, DateTime value2) =>
                          value2.compareTo(value1),
                      itemComparator: (Message m1, Message m2) =>
                          m2.createdAt.compareTo(m1.createdAt),
                      separator: SizedBox(height: 1.0),
                      itemScrollController: itemScrollController,
                      stickyHeaderBackgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      indexedItemBuilder: (itemContext, message, index) {
                        return MessageTile<ChannelMessagesCubit>(
                          message: message,
                          isDirect: false,
                          key: ValueKey(message.hash),
                          isSenderHidden: false,
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
                      Text(AppLocalizations.of(context)!.noPinnedMessages,
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
                    padding: const EdgeInsets.only(bottom: 10.0),
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
                                message: AppLocalizations.of(context)!
                                    .unpinnedNumber(pinnedMessages),
                                duration: Duration(seconds: 2));
                          } else {
                            Utilities.showSimpleSnackBar(
                                context: context,
                                message: AppLocalizations.of(context)!
                                    .somethingWentWrong);
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
                                  AppLocalizations.of(context)!
                                      .unpinAllMessages,
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
