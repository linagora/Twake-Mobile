import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_state.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/widgets/sheets/collaborators_list.dart';
import 'package:twake/widgets/sheets/workspace_info_form.dart';

class AddWorkspaceFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workspaceFlowWidgets = [
      WorkspaceInfoForm(),
      CollaboratorsList(),
    ];
    return BlocBuilder<AddWorkspaceCubit, AddWorkspaceState>(
      buildWhen: (_, current) => current is StageUpdated,
      builder: (context, state) {
        var i = 0;
        if (state is StageUpdated) {
          // print('Current stage: ${state.stage}');
          switch (state.stage) {
            case FlowStage.info:
              i = 0;
              break;
            case FlowStage.collaborators:
              i = 1;
              break;
          }
        }
        return IndexedStack(
          index: i,
          children: workspaceFlowWidgets,
        );
      },
    );
  }
}
