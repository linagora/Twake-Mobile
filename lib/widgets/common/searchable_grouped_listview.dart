import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/utils/dateformatter.dart';

class SearchableChatView extends StatefulWidget {
  final List<Message> messages;
  final bool reverse;
  final Widget Function(BuildContext context, Message element, int index)
      indexedItemBuilder;
  // use this controller to jumpTo specific message
  final SearchableGroupChatController? searchableChatController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final int initialScrollIndex;
  final ItemPositionsListener? itemPositionListener;
  final Widget Function(Message)? groupSeparatorBuilder;

  SearchableChatView({
    required this.indexedItemBuilder,
    required this.messages,
    this.reverse = false,
    this.searchableChatController,
    this.physics,
    this.shrinkWrap = false,
    this.initialScrollIndex = 0,
    this.itemPositionListener,
    this.groupSeparatorBuilder,
  });

  State<SearchableChatView> createState() => _SearchableChatViewState();
}

class _SearchableChatViewState extends State<SearchableChatView> {
  late SearchableGroupChatController _controller;
  Message? highlightMessage;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.searchableChatController ?? SearchableGroupChatController();
    _controller._bind(this, widget.messages.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return StickyGroupedListView<Message, DateTime>(
      initialScrollIndex: widget.initialScrollIndex,
      elements: widget.messages,
      disableHeader: true,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemPositionsListener: widget.itemPositionListener,
      groupSeparatorBuilder: widget.groupSeparatorBuilder ??
          (Message msg) {
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
      itemScrollController: _controller,
      stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      reverse: widget.reverse,
      indexedItemBuilder: (context, message, index) {
        return widget.indexedItemBuilder(context, message, index);
      },
    );
  }

  void updateHighlightMessage(Message message) {
    setState(() {
      highlightMessage = message;
    });
  }
}

class SearchableGroupChatController extends GroupedItemScrollController {
  _SearchableChatViewState? _state;
  Message? _highlightMessage;
  final _animationDuration = Duration(milliseconds: 350);
  final _alignment = 0.5;

  void scrollToMessage(List<Message> messages, Message message) {
    super.scrollTo(
      index: messages.indexOf(message),
      duration: _animationDuration,
      automaticAlignment: false,
      alignment: _alignment,
    );

    _state!.updateHighlightMessage(message);
    _highlightMessage = message;
  }

  void scrollToMessagesWithIndex(List<Message> messages, int index) {
    super.scrollTo(
      index: index,
      duration: _animationDuration,
      automaticAlignment: false,
      alignment: _alignment,
    );

    _state!.updateHighlightMessage(messages[index]);
    _highlightMessage = messages[index];
  }

  void jumpToMessage(List<Message> messages, int index) {
    super.jumpTo(
      index: index,
      automaticAlignment: false,
      alignment: _alignment,
    );

    _state!.updateHighlightMessage(messages[index]);
    _highlightMessage = messages[index];
  }

  Message? get highlightMessage => _highlightMessage;

  void _bind(_SearchableChatViewState state, List<Message> messages) {
    assert(_state == null);
    _state = state;
  }
}
