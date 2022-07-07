import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/searchable_grouped_listview.dart';
import 'package:twake/widgets/common/unread_border.dart';
import 'package:twake/widgets/common/unread_counter.dart';

class UnreadMessagesWidget extends StatefulWidget {
  final List<Message> messages;
  final Message? startMessage;
  final Message? latestMessage;
  final int userLastAccess;
  final Widget Function(BuildContext context, Message message, int index)
      indexedItemBuilder;
  // use only one controller for jump to item
  final SearchableGroupChatController jumpController;
  final ItemPositionsListener itemPositionsListener;

  UnreadMessagesWidget({
    required this.messages,
    this.startMessage,
    this.latestMessage,
    required this.userLastAccess,
    required this.indexedItemBuilder,
    required this.itemPositionsListener,
    required this.jumpController,
  });

  @override
  State<StatefulWidget> createState() => _UnreadMessagesWidgetState();
}

class _UnreadMessagesWidgetState extends State<UnreadMessagesWidget> {
  late List<Message> _messages;
  late Message? _startMessage;
  int unreadCounter = 0;
  List<Message> unreadThreads = [];
  Message? firstUnreadMessage;
  Message? firstUnreadMsgThread;
  late final userLastAccess;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
    _startMessage = widget.startMessage;

    userLastAccess = widget.userLastAccess;

    _messages.sort((a, b) => a.createdAt
        .compareTo(b.createdAt)); // sort message from oldest to latest

    Iterable<Message> unreadMessages =
        _messages.where((message) => message.createdAt > userLastAccess);
    // get number of unread messages
    unreadCounter = unreadMessages.length;
    firstUnreadMessage =
        unreadMessages.isNotEmpty ? unreadMessages.first : null;
    // contain unread Thread from oldest to latest
    unreadThreads = _messages
        .where((message) =>
            message.responsesCount > 0 &&
            message.lastReplies!.isNotEmpty &&
            message.lastReply!.createdAt > userLastAccess)
        .toList();
    if (unreadThreads.isNotEmpty) {
      if (firstUnreadMessage == null || firstUnreadMessage != null &&
          unreadThreads.first.lastReply!.createdAt <
              firstUnreadMessage!.createdAt) {
        firstUnreadMsgThread = unreadThreads.first;
      }

      if (firstUnreadMsgThread != null) {
        NavigatorService.instance.navigate(
            channelId: firstUnreadMsgThread!.channelId,
            threadId: firstUnreadMsgThread!.threadId,
            reloadThreads: false,
            userLastAccessFromChat: userLastAccess);
      }
    }
  }

  @override
  void didUpdateWidget(covariant UnreadMessagesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latestMessage != this.widget.latestMessage) {
      final latestMessage = this.widget.latestMessage;
      if (latestMessage!.isOwnerMessage) {
        unreadCounter = 0;
      } else {
        unreadCounter += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: UnreadCounter(
        counter: unreadCounter,
        itemPositionsListener: widget.itemPositionsListener,
        onPressed: () =>
            widget.jumpController.scrollToMessagesWithIndex(_messages, 0),
      ),
      body: SearchableChatView(
          initialScrollIndex: _startMessage == null
              ? (unreadCounter > 0 ? unreadCounter - 1 : 0)
              : _messages.indexOf(_startMessage!),
          itemPositionListener: widget.itemPositionsListener,
          searchableChatController: widget.jumpController,
          reverse: true,
          messages: _messages,
          indexedItemBuilder: (_, message, index) {
            return unreadCounter > 0 && index == unreadCounter - 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const UnreadBorder(),
                      widget.indexedItemBuilder(context, message, index),
                    ],
                  )
                : widget.indexedItemBuilder(context, message, index);
          }),
    );
  }
}
