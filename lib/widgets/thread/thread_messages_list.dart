import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/widgets/message/message_tile.dart';

class ThreadMessagesList<T extends BaseChannelBloc> extends StatelessWidget {
  ThreadMessagesList();

  Widget buildThreadMessageColumn(MessagesState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<T>(
              message: state.threadMessage, hideShowAnswers: true),
        ),
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
            state.threadMessage.respCountStr + ' responses',
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
        if (state is MessagesLoaded)
          MessageTile<T>(message: state.messages.last),
        if (state is MessagesEmpty)
          // Expanded( child:
          Center(
            child: Text(
              state is ErrorLoadingMessages
                  ? 'Couldn\'t load messages, no connection'
                  : 'No responses yet',
            ),
          ),
        // ),
        if (state is MessagesLoading)
          // Expanded( child:
          Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadsBloc<T>, MessagesState>(
      builder: (ctx, state) => Expanded(
        child: state is MessagesLoaded
            ? ScrollablePositionedList.builder(
                reverse: true,
                itemCount: state.messageCount,
                itemBuilder: (ctx, i) {
                  if (i == state.messageCount - 1) {
                    return buildThreadMessageColumn(state);
                  } else {
                    return MessageTile<T>(
                      message: state.messages[i],
                      key: ValueKey(state.messages[i].id),
                    );
                  }
                },
              )
            : SingleChildScrollView(child: buildThreadMessageColumn(state)),
      ),
    );
  }
}
