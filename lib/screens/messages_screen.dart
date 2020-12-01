import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/models/direct.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/common/text_avatar.dart';
import 'package:twake_mobile/widgets/message/messages_groupped_list.dart';
import 'package:twake_mobile/widgets/message/message_edit_field.dart';

class MessagesScreen extends StatelessWidget {
  static const String route = '/messages';
  @override
  Widget build(BuildContext context) {
    final api = Provider.of<TwakeApi>(context, listen: false);
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final channelId = ModalRoute.of(context).settings.arguments as String;
    final provider = Provider.of<ChannelsProvider>(context, listen: false);
    var channel;
    try {
      channel = provider.getChannelById(channelId);
    } catch (_) {
      channel = provider.getDirectsById(channelId);
    }
    final correspondent = channel.runtimeType == Direct
        ? channel.members.firstWhere((m) {
            return !profile.isMe(m.userId);
          })
        : null;
    final messagesProviderF = Provider.of<MessagesProvider>(
      context,
      listen: false,
    );
    return Scaffold(
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
                Text(
                    channel.runtimeType == Channel
                        ? channel.name
                        : '${correspondent.firstName} ${correspondent.lastName}',
                    style: Theme.of(context).textTheme.headline6),
                Text('${channel.membersCount ?? 'No'} members',
                    style: Theme.of(context).textTheme.bodyText2),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: messagesProviderF.loadMessages(api, channelId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<MessagesProvider>(
              builder: (ctx, messagesProvider, child) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MessagesGrouppedList(messagesProvider.items),
                  child,
                ],
              ),
              child: MessageEditField((content) {
                Provider.of<TwakeApi>(context, listen: false).messageSend(
                    channelId: channelId,
                    content: content,
                    onSuccess: (Map<String, dynamic> message) {
                      messagesProviderF.addMessage(message);
                    });
              }),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
