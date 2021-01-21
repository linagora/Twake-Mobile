import 'package:flutter/material.dart';
import 'package:twake/models/message.dart';
import 'package:twake/widgets/message/message_edit_field.dart';

class MessageEditModalSheet extends StatelessWidget {
  final Message message;

  MessageEditModalSheet(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            Text('Edit'),
          ]),
          // Divider(),
          MessageEditField(
            onMessageSend: (content) {},
            onTextUpdated: (content) {},
            autofocus: true,
          ),
        ],
      ),
    );
  }
}
