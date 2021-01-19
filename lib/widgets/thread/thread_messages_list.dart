import 'package:flutter/material.dart';
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
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                  color: Color(0xffEEEEEE),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    threadMessage.respCountStr + ' responses',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff92929C),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                  color: Color(0xffEEEEEE),
                ),
                SizedBox(
                  height: 12.0,
                ),
                MessageTile<T>(message: responses[i]),
              ],
            );
          } else {
            return MessageTile<T>(
              message: responses[i],
              key: ValueKey(responses[i].id),
            );
          }
        },
      ),
    );
  }
}
