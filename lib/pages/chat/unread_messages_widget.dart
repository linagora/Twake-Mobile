import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_state.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/searchable_grouped_listview.dart';
import 'package:twake/widgets/common/unread_border.dart';
import 'package:twake/widgets/common/unread_counter.dart';

class UnreadMessagesWidget extends StatefulWidget {
  final List<Message> messages;
  final Message? startMessage;
  final Widget Function(
          BuildContext context, Message message, int index, bool isSenderHidden)
      indexedItemBuilder;
  // use only one controller for jump to item
  final SearchableGroupChatController jumpController;
  final ItemPositionsListener itemPositionsListener;

  UnreadMessagesWidget({
    required this.messages,
    this.startMessage,
    required this.indexedItemBuilder,
    required this.itemPositionsListener,
    required this.jumpController,
  });

  @override
  State<StatefulWidget> createState() => _UnreadMessagesWidgetState();
}

class _UnreadMessagesWidgetState extends State<UnreadMessagesWidget> {
  late List<Message> _messages;
  Message? _startMessage;

  @override
  initState() {
    super.initState();
    _messages = widget.messages;

    UnreadMessagesState state = Get.find<ChannelUnreadMessagesCubit>().state;
    if (state is UnreadMessagesThreadFound && state.firstUnreadThread != null) {
      NavigatorService.instance.navigate(
          channelId: state.firstUnreadThread!.channelId,
          threadId: state.firstUnreadThread!.threadId,
          reloadThreads: false,
          userLastAccessFromChat: state.userLastAccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelUnreadMessagesCubit, UnreadMessagesState>(
        bloc: Get.find<ChannelUnreadMessagesCubit>(),
        builder: ((_, state) {
          int? unreadCounter;
          String? id;
          if (state is UnreadMessagesFound) {
            unreadCounter = state.unreadCounter;
          } else {
            unreadCounter = null;
          }
          bool hasUnreadCounter = unreadCounter != null && unreadCounter > 0;
          return Scaffold(
            floatingActionButton: UnreadCounter(
                counter: unreadCounter ?? 0,
                itemPositionsListener: widget.itemPositionsListener,
                onPressed: () {
                  // scroll to latest message
                  final latestMessage = _messages.reduce((value, element) =>
                      value.createdAt > element.createdAt ? value : element);
                  widget.jumpController
                      .scrollToMessage(_messages, latestMessage);
                }),
            body: SearchableChatView(
                itemPositionListener: widget.itemPositionsListener,
                searchableChatController: widget.jumpController,
                messages: _messages,
                reverse: true,
                initialScrollIndex: _startMessage == null
                    ? hasUnreadCounter
                        ? unreadCounter - 1
                        : 0
                    : _messages.indexOf(_startMessage!),
                indexedItemBuilder: (_, message, index) {
                  bool isSenderHidden = false;
                  (index == 0)
                      ? id = message.userId
                      : id == message.userId
                          ? isSenderHidden = true
                          : isSenderHidden = false;
                  id = message.userId;
                  return hasUnreadCounter && index == unreadCounter! - 1
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const UnreadBorder(),
                            widget.indexedItemBuilder(
                                context, message, index, isSenderHidden),
                          ],
                        )
                      : widget.indexedItemBuilder(
                          context, message, index, isSenderHidden);
                }),
          );
        }));
  }
}
