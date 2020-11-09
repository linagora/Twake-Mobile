import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';

class MessagesScreen extends StatelessWidget {
  static const String route = '/messages';
  @override
  Widget build(BuildContext context) {
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channelId = ModalRoute.of(context).settings.arguments as String;
    final messagesProvider =
        Provider.of<MessagesProvider>(context, listen: false);
    messagesProvider.loadMessages(api, channelId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your messages'),
      ),
      body: Consumer<MessagesProvider>(
        builder: (ctx, messagesProvider, _) {
          return messagesProvider.loaded
              ? ListView(
                  children:
                      Provider.of<MessagesProvider>(context, listen: false)
                          .items
                          .map((m) => MessageTile(m))
                          .toList(),
                )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
// TODO clean up and optimize
