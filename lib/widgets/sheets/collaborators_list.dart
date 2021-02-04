import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_state.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollaboratorsList extends StatefulWidget {
  @override
  _CollaboratorsListState createState() => _CollaboratorsListState();
}

class _CollaboratorsListState extends State<CollaboratorsList> {
  var _canInvite = false;

  void _return() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>().setFlowStage(FlowStage.info);
  }

  void _invite() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>().setFlowStage(FlowStage.info);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SheetTitleBar(
          title: 'Invite',
          leadingTitle: 'Back',
          leadingAction: () => _return(),
          trailingTitle: 'Invite',
          trailingAction: _canInvite ? () => _invite() : null,
        ),
      ],
    );
  }
}
