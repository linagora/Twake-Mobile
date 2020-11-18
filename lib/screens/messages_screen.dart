import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/widgets/common/text_avatar.dart';
import 'package:collection/collection.dart';

// import 'package:twake_mobile/services/twake_socket.dart';

class MessagesScreen extends StatelessWidget {
  static const String route = '/messages';
  @override
  Widget build(BuildContext context) {
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channelId = ModalRoute.of(context).settings.arguments as String;
    final channel = Provider.of<ChannelsProvider>(context, listen: false)
        .getById(channelId);

    final messagesProvider =
        Provider.of<MessagesProvider>(context, listen: false);
    messagesProvider.loadMessages(api, channelId);
    return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.grey[300],
          toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15)
              .round()), // taking into account current appBar height to calculate a new one
          title: Row(
            children: [
              TextAvatar(channel.icon, emoji: true),
              SizedBox(width: Dim.wm2),
              Text(channel.name, style: Theme.of(context).textTheme.headline6),
            ],
          ),
        ),
        body: Consumer<MessagesProvider>(
          builder: (ctx, messagesProvider, _) {
            return messagesProvider.loaded
                ? MessagesScrollView(
                    Provider.of<MessagesProvider>(context, listen: false).items,
                  )
                : Center(child: CircularProgressIndicator());
          },
        ));
  }
}
// TODO clean up and optimize

// StreamBuilder(
// stream: socket.stream,
// builder: (ctx, snapshot) {
// return Center(
// child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
// );
// },
// ),
//

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

    return ListView(
      children: groups.map((g) {
        return Column(children: [
          Text(DateFormatter.getVerboseDateTime(g.messages[0].creationDate)),
          ...g.messages.map((m) => MessageTile(m)).toList(),
        ]);
      }).toList(),
    );
  }
}

class MessageGroup {
  final DateTime datetime;
  List<Message> messages;
  MessageGroup(this.datetime, {this.messages});

  void addMessage(Message message) => messages.add(message);
}
