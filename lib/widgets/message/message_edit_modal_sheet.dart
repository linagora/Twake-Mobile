import 'package:flutter/material.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/models/message.dart';
import 'package:twake/widgets/message/message_edit_field.dart';

class MessageEditModalSheet extends StatelessWidget {
  final Message message;
  final Function onMessageSend;

  MessageEditModalSheet(this.message, {this.onMessageSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: MessageEditField(
        onMessageSend: onMessageSend,
        onTextUpdated: (content) {},
        initialText: message.content.originalStr,
        autofocus: true,
      ),
    );
  }
}
