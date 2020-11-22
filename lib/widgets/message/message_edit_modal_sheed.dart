import 'package:flutter/material.dart';
// import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/widgets/message/reply_field.dart';

class MessageEditModalSheet extends StatelessWidget {
  final Message message;
  MessageEditModalSheet(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // height: Dim.heightPercent(20),
      // padding: EdgeInsets.all(Dim.wm2),
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
          ReplyField(message: message, autofocus: true),
        ],
      ),
    );
  }
}
