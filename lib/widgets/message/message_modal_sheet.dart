import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/models/message.dart';

class MessageModalSheet extends StatefulWidget {
  final Message message;
  final void Function(BuildContext) onReply;
  final void Function(BuildContext) onDelete;
  final void Function() onCopy;
  final bool isThread;

  const MessageModalSheet(
    this.message, {
    this.isThread: false,
    this.onReply,
    this.onDelete,
    this.onCopy,
    Key key,
  }) : super(key: key);

  @override
  _MessageModalSheetState createState() => _MessageModalSheetState();
}

class _MessageModalSheetState extends State<MessageModalSheet> {
  @override
  Widget build(BuildContext context) {
    final bool isMe =
        BlocProvider.of<ProfileBloc>(context).isMe(widget.message.userId);
    return Container(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isThread)
              ListTile(
                leading: Icon(Icons.reply_sharp),
                title: Text(
                  'Reply',
                  style: Theme.of(context).textTheme.headline6,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onReply(context);
                },
              ),
            if (!widget.isThread) Divider(),
            if (isMe && widget.message.responsesCount == 0)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.red),
                ),
                onTap: () {
                  widget.onDelete(context);
                },
              ),
            if (isMe) Divider(),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text(
                'Copy',
                style: Theme.of(context).textTheme.headline6,
              ),
              onTap: widget.onCopy,
            ),
          ],
        ),
      ),
    );
  }
}
