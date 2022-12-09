import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_tile.dart';

class ThreadMessagesList<T extends BaseMessagesCubit> extends StatefulWidget {
  final Channel parentChannel;

  const ThreadMessagesList({required this.parentChannel});

  @override
  _ThreadMessagesListState createState() => _ThreadMessagesListState<T>();
}

class _ThreadMessagesListState<T extends BaseMessagesCubit>
    extends State<ThreadMessagesList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ThreadMessagesCubit, MessagesState>(
        bloc: Get.find<ThreadMessagesCubit>(),
        builder: (ctx, state) {
          if (state is MessagesLoadSuccess) {
            state.messages
                .sort((m1, m2) => m2.createdAt.compareTo(m1.createdAt));

            return state.messages.length != 1
                ? ThreadMessagesScrollView(
                    messages: state.messages,
                    parentChannel: widget.parentChannel,
                  )
                : SingleChildScrollView(
                    child: MessageColumn(
                      message: state.messages.first,
                      parentChannel: widget.parentChannel,
                    ),
                  );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class ThreadMessagesScrollView extends StatelessWidget {
  final List<Message> messages;
  final Channel parentChannel;
  const ThreadMessagesScrollView(
      {Key? key, required this.messages, required this.parentChannel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: MessageColumn(
            message: messages.last,
            parentChannel: parentChannel,
          ),
        ),
        _ScrollableMessagesList(
          messages: messages.getRange(0, messages.length - 1).toList(),
          parentChannel: parentChannel,
        ),
      ],
    );
  }
}

class _ScrollableMessagesList extends StatefulWidget {
  final List<Message> messages;
  final Channel parentChannel;

  _ScrollableMessagesList({
    required this.messages,
    required this.parentChannel,
  });

  @override
  State<StatefulWidget> createState() => _ScrollableMessagesListState();
}

class _ScrollableMessagesListState extends State<_ScrollableMessagesList> {
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ScrollablePositionedList.builder(
        itemPositionsListener: _itemPositionsListener,
        itemCount: widget.messages.length,
        itemScrollController: itemScrollController,
        reverse: true,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              Get.find<MessageAnimationCubit>().startAnimation(
                messagesListContext: context,
                longPressMessage: widget.messages[index],
                longPressIndex: index, // because the replied message
                itemPositionsListener: _itemPositionsListener,
              );
            },
            child: MessageTile<ChannelMessagesCubit>(
              message: widget.messages[index],
              isDirect: widget.parentChannel.isDirect,
              key: ValueKey(widget.messages[index].hash),
              isThread: true,
            ),
          );
        },
      ),
    );
  }
}

class MessageColumn extends StatelessWidget {
  final Message message;
  final Channel parentChannel;

  const MessageColumn({required this.message, required this.parentChannel});

  build(ctx) {
    final state = Get.find<ThreadMessagesCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: Dim.heightPercent(35)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: MessageTile<ThreadMessagesCubit>(
                    message: message,
                    isDirect: parentChannel.isDirect,
                    isThread: true,
                    isHeadInThred: true,
                    key: ValueKey(message.hash),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state is MessagesLoadSuccess)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 1),
                child: Text(
                    AppLocalizations.of(ctx)!
                        .replyPlural(state.messages.length - 1),
                    style: Theme.of(ctx)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.normal, fontSize: 15)),
              ),
            ],
          ),
        SizedBox(
          height: 8.0,
        ),
        Divider(
          thickness: 5.0,
          height: 2.0,
          color: Theme.of(ctx).colorScheme.secondary.withOpacity(0.7),
        ),
        SizedBox(
          height: 4.0,
        ),
      ],
    );
  }
}
/* If we need groupBy in the future
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StickyGroupedListView<Message, DateTime>(
        elements: widget.messages,
        floatingHeader: false,
        reverse: true,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
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
                    .headline2!
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
          return GestureDetector(
            onLongPress: () {
              Get.find<MessageAnimationCubit>().startAnimation(
                messagesListContext: context,
                longPressMessage: message,
                longPressIndex: index, // because the replied message
                itemPositionsListener: _itemPositionsListener,
              );
            },
            child: MessageTile<ChannelMessagesCubit>(
              message: message,
              isDirect: widget.parentChannel.isDirect,
              key: ValueKey(message.hash),
              isSenderHidden: false,
              isHeadInThred: true,
              isThread: true,
            ),
          );
        },
      ),
    );
  }
}*/
