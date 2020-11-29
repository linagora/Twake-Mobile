import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';

class ThreadMessagesList extends StatefulWidget {
  final List<Message> responses;
  ThreadMessagesList(this.responses);

  @override
  _ThreadMessagesListState createState() => _ThreadMessagesListState();
}

class _ThreadMessagesListState extends State<ThreadMessagesList> {
  final conroller = ItemScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        reverse: true,
        itemCount: widget.responses.length,
        itemBuilder: (ctx, i) {
          return ChangeNotifierProvider.value(
            value: widget.responses[i],
            child: MessageTile(widget.responses[i], isThread: true),
          );
        },
        itemScrollController: conroller,
      ),
    );
  }
}
