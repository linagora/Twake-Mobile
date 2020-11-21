import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/message.dart';

class MessageModalSheet extends StatelessWidget {
  final Message message;
  final void Function(BuildContext) onReply;
  const MessageModalSheet(
    this.message, {
    this.onReply,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dim.heightPercent(30),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
            onTap: () {},
          ),
          Divider(),
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
