import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';

class MessageModalSheet extends StatefulWidget {
  final String userId;
  final String messageId;
  final int responsesCount;
  final void Function(BuildContext, String) onReply;
  final void Function(BuildContext) onDelete;
  final Function onCopy;
  final bool isThread;

  const MessageModalSheet({
    this.userId,
    this.messageId,
    this.responsesCount,
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
    final bool isMe = BlocProvider.of<ProfileBloc>(context).isMe(widget.userId);
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
                  style: Theme.of(context).textTheme.headline2,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onReply(context, widget.messageId);
                },
              ),
            if (!widget.isThread) Divider(),
            if (isMe && widget.responsesCount == 0)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
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
                style: Theme.of(context).textTheme.headline2,
              ),
              onTap: widget.onCopy,
            ),
          ],
        ),
      ),
    );
  }
}
