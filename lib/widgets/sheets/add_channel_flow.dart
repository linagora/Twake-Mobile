import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/channel_info_form.dart';
import 'package:twake/widgets/sheets/participants_list.dart';

class AddChannelFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Build call');
    final channelFlowWidgets = [
      ChannelInfoForm(),
      BlocProvider<UserBloc>(
        create: (_) => UserBloc(ProfileBloc.userId),
        child: ParticipantsList(),
      ),
    ];
    return BlocBuilder<AddChannelBloc, AddChannelState>(
      buildWhen: (_, current) => current is StageUpdated,
      builder: (context, state) {
        print('State! - $state');

        var i = 0;
        if (state is StageUpdated) {
          switch (state.stage) {
            case FlowStage.info:
              i = 0;
              break;
            case FlowStage.participants:
              i = 1;
              break;
          }
        }
        return IndexedStack(
          index: i,
          children: channelFlowWidgets,
        );
      },
    );
  }
}
