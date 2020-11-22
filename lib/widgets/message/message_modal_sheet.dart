import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/profile_provider.dart';

class MessageModalSheet extends StatelessWidget {
  final Message message;
  final void Function(BuildContext) onReply;
  final void Function(BuildContext) onEdit;
  const MessageModalSheet(
    this.message, {
    this.onReply,
    this.onEdit,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMe = Provider.of<ProfileProvider>(context, listen: false)
        .isMe(message.sender.id);
    return Container(
      height: Dim.heightPercent(30),
      child: Column(
        children: [
          /// Show edit only if the sender of the message is the person,
          /// who's currently logged in
          if (isMe)
            ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              onTap: () {
                onEdit(context);
              },
            ),
          if (isMe) Divider(),
          ListTile(
            leading: Icon(Icons.reply_sharp),
            title: Text('Reply'),
            onTap: () {
              onReply(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.copy),
            title: Text(
              'Copy',
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
