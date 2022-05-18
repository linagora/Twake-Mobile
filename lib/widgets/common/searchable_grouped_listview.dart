
import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/highlight_message.dart';

class SearchableChatView extends StatefulWidget {
  final List<Message> messages;
  final bool reverse;
  final Widget Function(BuildContext context, Message element, int index)
    indexedItemBuilder;
  // use this controller to jumpTo specific message
  final SearchableGroupChatController? groupChatController;

  SearchableChatView({
    required this.indexedItemBuilder, 
    required this.messages, 
    this.reverse = false,
    this.groupChatController,
  });

  State<SearchableChatView> createState() => _SearchableChatViewState();
}

class _SearchableChatViewState extends State<SearchableChatView> {
  late SearchableGroupChatController _controller;
  Message? highlightMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.groupChatController ?? SearchableGroupChatController();
    _controller._bind(this, widget.messages.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return StickyGroupedListView<Message, DateTime>(
      elements: widget.messages,
      key: PageStorageKey<String>('uniqueKey'),
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
        final DateTime dt =
            DateTime.fromMillisecondsSinceEpoch(m.createdAt);
        return DateTime(dt.year, dt.month, dt.day);
      },
      groupComparator: (DateTime value1, DateTime value2) =>
          value2.compareTo(value1),
      itemComparator: (Message m1, Message m2) =>
        m2.createdAt.compareTo(m1.createdAt),
      separator: SizedBox(height: 1.0),
      itemScrollController: _controller,
      stickyHeaderBackgroundColor: 
        Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(bottom: 12.0),
      reverse: widget.reverse,
      indexedItemBuilder: (context, message, index) {
        return highlightMessage == null || highlightMessage != message 
          ? widget.indexedItemBuilder(context, message, index)
          : HighlightComponent(
            component: widget.indexedItemBuilder(context, message, index)
            );
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

  void jumpMessage(List<Message> messages, Message message) {
    super.scrollTo(
      index: messages.indexOf(message), 
      duration: Duration(seconds: 1),
      automaticAlignment: false,
      alignment: 0.5,
    );
    
    _state!.updateHighlightMessage(message);
  }

  void _bind(_SearchableChatViewState state, List<Message> messages) {
    assert(_state == null);
    _state = state;
  }
}
