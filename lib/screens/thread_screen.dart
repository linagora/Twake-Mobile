import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/models/direct.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/common/text_avatar.dart';
import 'package:twake_mobile/widgets/message/message_edit_field.dart';
import 'package:twake_mobile/widgets/message/message_tile.dart';
import 'package:twake_mobile/widgets/thread/thread_messages_list.dart';

class ThreadScreen extends StatelessWidget {
  static const String route = '/thread';
  @override
  Widget build(BuildContext context) {
    final params =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var channel;
    final provider = Provider.of<ChannelsProvider>(context, listen: false);
    try {
      channel = provider.getChannelById(params['channelId']);
    } catch (_) {
      channel = provider.getDirectsById(params['channelId']);
    }
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final messagesProvider = Provider.of<MessagesProvider>(context);
    final Message message =
        messagesProvider.getMessageById(params['messageId']);
    final correspondent = channel.runtimeType == Direct
        ? channel.members.firstWhere((m) {
            return !profile.isMe(m.userId);
          })
        : null;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.grey[300],
          toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15)
              .round()), // taking into account current appBar height to calculate a new one
          title: Row(
            children: [
              if (channel.runtimeType == Direct)
                ImageAvatar(correspondent.thumbnail),
              if (channel.runtimeType == Channel)
                TextAvatar(channel.icon, emoji: true, fontSize: Dim.tm4()),
              SizedBox(width: Dim.widthMultiplier),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: channel.runtimeType == Channel
                                ? channel.name
                                : '${correspondent.firstName} ${correspondent.lastName}',
                            style: Theme.of(context).textTheme.headline6),
                        TextSpan(
                            text: ' - thread',
                            style: Theme.of(context).textTheme.subtitle2),
                      ],
                    ),
                  ),
                  Text('${channel.membersCount ?? 'No'} members',
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
            // Show main message only if keyboard is hidden
            // otherwise it causes ugly shrinking of responses list
            if (MediaQuery.of(context).viewInsets.bottom == 0)
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
              child: Text('${message.responsesCount ?? 'No'} responses'),
            ),
            Divider(color: Colors.grey[200]),
            ThreadMessagesList((message.responses ?? []).reversed.toList()),
            MessageEditField((content) {
              Provider.of<TwakeApi>(context, listen: false).messageSend(
                channelId: message.channelId,
                content: content,
                onSuccess: (Map<String, dynamic> _message) {
                  messagesProvider.addMessage(
                    _message,
                    parentMessageId: message.id,
                  );
                },
                parentMessageId: message.id,
              );
            }),
          ],
        ),
      ),
    );
  }
}
