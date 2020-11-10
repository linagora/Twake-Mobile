import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';
import 'package:twake_mobile/services/twake_socket.dart';

class MessagesScreen extends StatelessWidget {
  static const String route = '/messages';
  @override
  Widget build(BuildContext context) {
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channelId = ModalRoute.of(context).settings.arguments as String;
    final messagesProvider =
        Provider.of<MessagesProvider>(context, listen: false);
    messagesProvider.loadMessages(api, channelId);
    final socket = TwakeSocket(api.token);
    socket.pushData('Hello');
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            socket.pushData('''["init", {"token":"${api.token}"}]''');
          },
          child: Icon(Icons.music_note),
        ),
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
        ));
  }
}
// TODO clean up and optimize

// StreamBuilder(
// stream: socket.stream,
// builder: (ctx, snapshot) {
// print('got data');
// print(snapshot.error);
// print(snapshot.data);
// return Center(
// child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
// );
// },
// ),
//
