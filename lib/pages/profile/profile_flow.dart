import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/pages/profile/edit_profile.dart';
import 'package:twake/pages/profile/profile.dart';

class AddWorkspaceFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileFlowWidgets = [
      Profile(),
      EditProfile(),
    ];
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (_, current) => current is ProfileStageUpdated,
      builder: (context, state) {
        var i = 0;
        if (state is ProfileStageUpdated) {
          // print('Current stage: ${state.stage}');
          switch (state.stage) {
            case ProfileFlowStage.info:
              i = 0;
              break;
            case ProfileFlowStage.edit:
              i = 1;
              break;
          }
        }
        return IndexedStack(
          index: i,
          children: profileFlowWidgets,
        );
      },
    );
  }
}
