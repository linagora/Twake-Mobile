import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_state.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/jumpable_pinned_messages.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/utils/bubble_side.dart';
import 'package:twake/widgets/common/highlight_component.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/common/searchable_grouped_listview.dart';
import 'package:twake/widgets/common/unread_border.dart';
import 'package:twake/widgets/common/unread_counter.dart';

class ThreadMessagesList<T extends BaseMessagesCubit> extends StatefulWidget {
  final Channel parentChannel;
  final Message? pinnedMessage;

  const ThreadMessagesList({required this.parentChannel, this.pinnedMessage});

  @override
  _ThreadMessagesListState createState() => _ThreadMessagesListState<T>();
}

class _ThreadMessagesListState<T extends BaseMessagesCubit>
    extends State<ThreadMessagesList> {
  double? appBarHeight;
  List<Widget> widgets = [];
  List<Message> _messages = <Message>[];
  int _highlightIndex = -1;
  bool isJump = false;
  ItemScrollController _jumpController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  ScrollPhysics _physics = ClampingScrollPhysics();

  @override
  void initState() {
    super.initState();

    if (Get.arguments[0] != null) {
      // jump to selected pinned message
      Message pinnedMessage = Get.arguments[0];

      isJump = true;
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        _highlightIndex =
            _messages.length - 1 - _messages.indexOf(pinnedMessage);
        // i don't know why scrollTo animation work not correctly, so i use jumpTo
        _jumpController.jumpTo(index: _highlightIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ThreadMessagesCubit, MessagesState>(
        bloc: Get.find<ThreadMessagesCubit>(),
        builder: (ctx, state) {
          if (state is MessagesLoadSuccess) {
            isJump
                ? _messages = state.messages.reversed.toList()
                : _messages = state.messages;
          }
          return state is MessagesLoadSuccess && _messages.length != 0
              ? _buildThredMessages()
              : SingleChildScrollView(
                  child: MessageColumn<T>(
                    message: _messages.first,
                    parentChannel: widget.parentChannel,
                  ),
                );
        },
      ),
    );
  }

  Widget _buildThredMessages() {
    return Column(
      children: [
        SingleChildScrollView(
          child: MessageColumn<T>(
            message: isJump ? _messages.last : _messages.first,
            parentChannel: widget.parentChannel,
          ),
        ),
        Expanded(
          child: JumpablePinnedMessages(
            jumpToMessage: ((messages, jumpedMessage) {
              _jumpController.jumpTo(index: _highlightIndex);
            }),
            messages: _messages,
            isDirect: widget.parentChannel.isDirect,
            child: BlocBuilder<ThreadUnreadMessagesCubit, UnreadMessagesState>(
              bloc: Get.find<ThreadUnreadMessagesCubit>(),
              builder: (context, state) {
                int? unreadCounter;
                if (state is! UnreadMessagesThreadFound) {
                  unreadCounter = null;
                } else {
                  unreadCounter = state.unreadCounter;
                }

                return Scaffold(
                  floatingActionButton: UnreadCounter(
                      counter: unreadCounter ?? 0,
                      itemPositionsListener: _itemPositionsListener,
                      onPressed: () {
                        // scroll to latest message
                        final latestMessage = _messages.reduce(
                            (value, element) =>
                                value.createdAt > element.createdAt
                                    ? value
                                    : element);
                        _jumpController.jumpTo(
                            index: isJump
                                ? _messages.indexOf(latestMessage)
                                : _messages.length -
                                    1 -
                                    _messages.indexOf(latestMessage));
                      }),
                  body: ScrollablePositionedList.builder(
                    initialScrollIndex:
                        unreadCounter != null ? max(0, unreadCounter - 1) : 0,
                    itemCount: _messages.length,
                    itemScrollController: _jumpController,
                    physics: _physics,
                    reverse: isJump ? false : true,
                    shrinkWrap: isJump ? false : true,
                    itemBuilder: (context, index) {
                      return HighlightComponent(
                          component: unreadCounter != null &&
                                  unreadCounter > 0 &&
                                  index == unreadCounter - 1
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const UnreadBorder(),
                                    _buildIndexedMessage(context, index),
                                  ],
                                )
                              : _buildIndexedMessage(context, index),
                          highlightColor: Theme.of(context).backgroundColor,
                          highlightWhen: _highlightIndex == index);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndexedMessage(BuildContext context, int index) {
    //conditions for determining the shape of the bubble sides
    final List<bool> bubbleSides = bubbleSide(_messages, index, false);
    if ((index == 0 && isJump) || (index == _messages.length - 1 && !isJump)) {
      return SizedBox.shrink();
    } else if (index == _messages.length - 2) {
      // the top side of the first answer in a thread should always be round
      return MessageTile<ThreadMessagesCubit>(
        message: _messages[_messages.length - 1 - index],
        key: ValueKey(_messages[_messages.length - 1 - index].hash),
        channel: widget.parentChannel,
        downBubbleSide: bubbleSides[1],
        upBubbleSide: true,
        isThread: true,
      );
    } else {
      return MessageTile<ThreadMessagesCubit>(
        message: _messages[_messages.length - 1 - index],
        key: ValueKey(_messages[_messages.length - 1 - index].hash),
        channel: widget.parentChannel,
        downBubbleSide: bubbleSides[1],
        upBubbleSide: bubbleSides[0],
        isThread: true,
      );
    }
  }
}

class MessageColumn<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final Channel parentChannel;

  const MessageColumn({required this.message, required this.parentChannel});

  build(ctx) {
    final state = Get.find<ThreadMessagesCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<ThreadMessagesCubit>(
            channel: parentChannel,
            downBubbleSide: true,
            upBubbleSide: true,
            message: message,
            hideReaction: true,
            hideShowReplies: true,
            isThread: true,
            key: ValueKey(message.hash),
          ),
        ),
        if (state is MessagesLoadSuccess)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...message.reactions.map((r) {
                          return Reaction<T>(
                            message: message,
                            reaction: r,
                            isFirstInThread: true,
                          );
                        }),
                      ],
                    )),
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
          color: Theme.of(ctx).colorScheme.secondaryContainer,
        ),
        SizedBox(
          height: 4.0,
        ),
      ],
    );
  }
}
