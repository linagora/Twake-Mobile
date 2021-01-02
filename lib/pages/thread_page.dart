import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/direct.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/message/message_edit_field.dart';
import 'package:twake/widgets/message/message_tile.dart';
import 'package:twake/widgets/thread/thread_messages_list.dart';

class ThreadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      builder: (ctx, threadState) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            shadowColor: Colors.grey[300],
            toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15).round()),
            title: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              leading: threadState.parentChannel is Direct
                  ? StackedUserAvatars(
                      (threadState.parentChannel as Direct).members)
                  : TextAvatar(
                      threadState.parentChannel.icon,
                      emoji: true,
                      fontSize: Dim.tm4(),
                    ),
              title: Text(
                'Threaded replies',
                style: Theme.of(context).textTheme.headline6,
              ),
              subtitle: Text(
                threadState.parentChannel.name,
                style: Theme.of(context).textTheme.bodyText2,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocProvider<SingleMessageBloc>(
                    create: (_) => SingleMessageBloc(
                      (threadState as MessageSelected).threadMessage,
                    ),
                    child: MessageTile(),
                  ),
                  Divider(color: Colors.grey[200]),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Dim.heightMultiplier,
                      horizontal: Dim.wm4,
                    ),
                    child: Text((threadState as MessageSelected)
                            .threadMessage
                            .respCountStr +
                        ' responses'),
                  ),
                  Divider(color: Colors.grey[200]),
                  BlocBuilder<ThreadsBloc, MessagesState>(
                    builder: (ctx, state) => state is MessagesLoaded
                        ? ThreadMessagesList(state.messages)
                        : Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
                  MessageEditField((content) {
                    BlocProvider.of<MessagesBloc>(ctx).add(
                      SendMessage(
                        content: content,
                        threadId:
                            (threadState as MessageSelected).threadMessage.id,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
