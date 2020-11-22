// Unsuccessfull experiment with groupped scrollable view of messages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';

class MessagesScrollView extends StatefulWidget {
  final List<Message> messages;
  MessagesScrollView(this.messages);

  @override
  _MessagesScrollViewState createState() => _MessagesScrollViewState();
}

class _MessagesScrollViewState extends State<MessagesScrollView> {
  List<MessageGroup> groups = [];

  @override
  Widget build(BuildContext context) {
    final g = groupBy(widget.messages, (Message m) {
      final date = DateTime.fromMillisecondsSinceEpoch(m.creationDate * 1000);
      return DateTime(date.year, date.month, date.day);
    });
    g.entries.forEach((e) {
      groups.add(MessageGroup(e.key, messages: e.value));
    });

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          Provider.of<MessagesProvider>(context, listen: false)
              .loadMoreMessages();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (ctx, i) {
          return Column(children: [
            Text(DateFormatter.getVerboseDate(groups[i].datetime)),
            ...groups[i].messages.map((m) => MessageTile(m)).toList(),
          ]);
        },
      ),
    );
  }
}

class MessageGroup {
  final DateTime datetime;
  List<Message> messages;
  MessageGroup(this.datetime, {this.messages});

  void addMessage(Message message) => messages.add(message);
}
