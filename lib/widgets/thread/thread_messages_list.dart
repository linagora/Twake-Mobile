import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/widgets/message/message_tile.dart';
import 'package:twake/blocs/single_message_bloc.dart';

class ThreadMessagesList<T extends BaseChannelBloc> extends StatelessWidget {
  final List<Message> responses;
  final Message threadMessage;
  ThreadMessagesList(this.responses, {this.threadMessage});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        reverse: true,
        itemCount: responses.length,
        itemBuilder: (ctx, i) {
          if (i == responses.length - 1) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MessageTile<T>(message: threadMessage, hideShowAnswers: true),
                Divider(color: Colors.grey[200]),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Dim.heightMultiplier,
                    horizontal: Dim.wm4,
                  ),
                  child: Text(threadMessage.respCountStr + ' responses'),
                ),
                Divider(color: Colors.grey[200]),
                MessageTile<T>(message: responses[i]),
              ],
            );
          } else {
            return BlocProvider<SingleMessageBloc>(
              create: (_) => SingleMessageBloc(responses[i]),
              child: MessageTile<T>(message: responses[i]),
            );
          }
        },
      ),
    );
  }
}
