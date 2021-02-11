import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_cubit.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_state.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/repositories/channel_repository.dart';
import 'package:twake/widgets/sheets/collaborators_list.dart';
import 'package:twake/widgets/sheets/participants_list.dart';

class EditChannelFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final editChannelFlowWidgets = [
      CollaboratorsList(),
      BlocProvider<UserBloc>(
        create: (_) => UserBloc(ProfileBloc.userId),
        child: ParticipantsList(),
      ),
    ];
    return BlocBuilder<EditChannelCubit, EditChannelState>(
      buildWhen: (_, current) => current is EditChannelStageUpdated,
      builder: (context, state) {
        print('State! - $state');
        var i = 0;
        if (state is EditChannelStageUpdated) {
          switch (state.stage) {
            case EditFlowStage.manage:
              i = 0;
              break;
            case EditFlowStage.add:
              i = 1;
              break;
          }
        }
        return IndexedStack(
          index: i,
          children: editChannelFlowWidgets,
        );
      },
    );
  }
}
