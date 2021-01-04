import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/stacked_image_avatars.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/message/messages_groupped_list.dart';
import 'package:twake/widgets/message/message_edit_field.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        shadowColor: Colors.grey[300],
        toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15).round()),
        title: BlocBuilder<MessagesBloc, MessagesState>(
          builder: (ctx, state) => Row(
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
                    width: Dim.widthPercent(69),
                    child: Text(
                      state.parentChannel.name,
                      style: Theme.of(ctx).textTheme.headline6,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  Text('${state.parentChannel.membersCount ?? 'No'} members',
                      style: Theme.of(ctx).textTheme.bodyText2),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MessagesGrouppedList(),
          MessageEditField(
            (content) {
              BlocProvider.of<MessagesBloc>(context).add(
                SendMessage(content: content),
              );
            },
          ),
        ],
      )),
    );
  }
}
