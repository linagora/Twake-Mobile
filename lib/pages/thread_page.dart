import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/direct.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/message/message_edit_field.dart';
import 'package:twake/widgets/thread/thread_messages_list.dart';

class ThreadPage<T extends BaseChannelBloc> extends StatelessWidget {
  final bool autofocus;
  ThreadPage({this.autofocus: false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadsBloc<T>, MessagesState>(
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            shadowColor: Colors.grey[300],
            toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15).round()),
            title: Row(
              children: [
                state.parentChannel is Direct
                    ? StackedUserAvatars((state.parentChannel as Direct).members)
                    : TextAvatar(
                  state.parentChannel.icon,
                  emoji: true,
                  fontSize: Dim.tm4(),
                ),
                SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Threaded replies',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff444444),
                      ),
                    ),
                    SizedBox(height: 1.0),
                    Text(
                      state.parentChannel.name,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff92929C),
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: Dim.heightPercent(88),
                minHeight: Dim.heightPercent(78),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state is MessagesLoaded)
                    ThreadMessagesList<T>(
                      state.messages,
                      threadMessage: state.threadMessage,
                    ),
                  if (state is MessagesEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          state is ErrorLoadingMessages
                              ? 'Couldn\'t load messages, no connection'
                              : 'No responses yet',
                        ),
                      ),
                    ),
                  if (state is MessagesLoading)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  MessageEditField(
                    (content) {
                      BlocProvider.of<ThreadsBloc<T>>(ctx).add(
                        SendMessage(
                          content: content,
                          channelId: state.parentChannel.id,
                          threadId: state.threadMessage.id,
                        ),
                      );
                    },
                    autofocus: autofocus,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
