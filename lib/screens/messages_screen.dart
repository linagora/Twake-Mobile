import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/widgets/common/text_avatar.dart';
import 'package:twake_mobile/widgets/message/messages_groupped_list.dart';
import 'package:twake_mobile/widgets/message/message_edit_field.dart';

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
    print('Loading messages');
    messagesProvider.loadMessages(api, channelId);
    return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.grey[300],
          toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15)
              .round()), // taking into account current appBar height to calculate a new one
          title: Row(
            children: [
              TextAvatar(channel.icon, emoji: true, fontSize: Dim.tm4()),
              SizedBox(width: Dim.widthMultiplier),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(channel.name,
                      style: Theme.of(context).textTheme.headline6),
                  Text('${channel.membersCount} members',
                      style: Theme.of(context).textTheme.bodyText2),
                ],
              ),
            ],
          ),
        ),
        body: Consumer<MessagesProvider>(
          builder: (ctx, messagesProvider, _) {
            return messagesProvider.loaded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MessagesGrouppedList(
                        Provider.of<MessagesProvider>(context, listen: false)
                            .items,
                      ),
                      MessageEditField(),
                    ],
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
