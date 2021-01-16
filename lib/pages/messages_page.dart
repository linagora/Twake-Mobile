import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/stacked_image_avatars.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/message/messages_grouped_list.dart';
import 'package:twake/widgets/message/message_edit_field.dart';

class MessagesPage<T extends BaseChannelBloc> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MessagesBloc<T>, MessagesState>(
      listener: (ctx, state) {
        if (state is ErrorLoadingMessages) {
          Navigator.of(ctx).pop(true);
        }
      },
      child: BlocBuilder<MessagesBloc<T>, MessagesState>(
        builder: (ctx, state) => Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            shadowColor: Colors.grey[300],
            toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15).round()),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((state.parentChannel is Direct))
                  StackedUserAvatars((state.parentChannel as Direct).members),
                if (state.parentChannel is Channel)
                  TextAvatar(
                    state.parentChannel.icon,
                    emoji: true,
                    fontSize: Dim.tm4(),
                  ),
                SizedBox(width: Dim.widthMultiplier),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Dim.widthPercent(67),
                      child: Text(
                        state.parentChannel.name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff444444),
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    if (state.parentChannel is Channel)
                      Text(
                        '${state.parentChannel.membersCount ?? 'No'} members',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff92929C),
                        ),
                      ),
                    if (state.parentChannel is Direct &&
                        state.parentChannel.membersCount > 1)
                      Text('${state.parentChannel.membersCount} members',
                          style: Theme.of(ctx).textTheme.bodyText2),
                  ],
                ),
              ],
            ),
          ),
          body: SafeArea(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state is MoreMessagesLoading)
                SizedBox(
                  height: Dim.hm4,
                  width: Dim.hm4,
                  child: Padding(
                    padding: EdgeInsets.all(Dim.widthMultiplier),
                    child: CircularProgressIndicator(),
                  ),
                ),
              MessagesGroupedList<T>(),
              MessageEditField((content) {
                BlocProvider.of<MessagesBloc<T>>(context).add(
                  SendMessage(content: content),
                );
              }),
            ],
          )),
        ),
      ),
    );
  }
}
