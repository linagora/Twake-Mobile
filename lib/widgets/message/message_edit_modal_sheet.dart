/* import 'package:flutter/material.dart';
import 'package:twake/blocs/single_message_bloc/single_message_bloc.dart';
import 'package:twake/models/message.dart';
import 'package:twake/widgets/message/compose_bar.dart';

class MessageEditModalSheet extends StatelessWidget {
  final Message message;
  final Function? onMessageSend;

  MessageEditModalSheet(this.message, {this.onMessageSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ComposeBar(
        onMessageSend: onMessageSend as dynamic Function(String, BuildContext)?,
        onTextUpdated: (content, context) {},
        initialText: message.content!.originalStr,
        autofocus: true,
      ),
    );
  }
}
 */
