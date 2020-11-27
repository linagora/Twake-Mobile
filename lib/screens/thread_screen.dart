import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/widgets/common/text_avatar.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';
import 'package:twake_mobile/widgets/message/message_edit_field.dart';
import 'package:twake_mobile/widgets/thread/thread_messages_list.dart';

class ThreadScreen extends StatelessWidget {
  static const String route = '/thread';
  @override
  Widget build(BuildContext context) {
    final params =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final Channel channel =
        Provider.of<ChannelsProvider>(context, listen: false)
            .getById(params['channelId']);
    final messagesProvider = Provider.of<MessagesProvider>(context);
    final Message message =
        messagesProvider.getMessageById(params['messageId']);
    return SafeArea(
      child: Scaffold(
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: channel.name,
                            style: Theme.of(context).textTheme.headline6),
                        TextSpan(
                            text: ' - thread',
                            style: Theme.of(context).textTheme.subtitle2),
                      ],
                    ),
                  ),
                  Text('${channel.membersCount} members',
                      style: Theme.of(context).textTheme.bodyText2),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: SingleChildScrollView(
                child: ChangeNotifierProvider.value(
                  value: message,
                  child: MessageTile(message, isThread: true),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: Dim.heightMultiplier),
              height: Dim.heightPercent(19),
            ),
            Divider(color: Colors.grey[200]),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dim.heightMultiplier,
                horizontal: Dim.wm4,
              ),
              child: Text('${message.responsesCount} responses'),
            ),
            Divider(color: Colors.grey[200]),
            ThreadMessagesList(message.responses.reversed.toList()),
            MessageEditField(),
          ],
        ),
      ),
    );
  }
}
