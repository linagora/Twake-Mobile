import 'package:flutter/material.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_bloc.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/repositories/add_channel_repository.dart'
    as add_channel_repo;
import 'package:twake/repositories/add_workspace_repository.dart'
    as add_workspace_repo;
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/sheets/add_channel_flow.dart';
import 'package:twake/widgets/sheets/add_direct_flow.dart';
import 'package:twake/widgets/sheets/add_workspace_flow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableScrollable extends StatelessWidget {
  final SheetFlow flow;

  const DraggableScrollable({Key key, this.flow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('Current flow: $flow');
    Widget content = AddChannelFlow();
    switch (flow) {
      case SheetFlow.channel:
        context
            .read<AddChannelBloc>()
            .add(SetFlowStage(add_channel_repo.FlowStage.info));
        content = AddChannelFlow();
        break;
      case SheetFlow.direct:
        content = AddDirectFlow();
        break;
      case SheetFlow.workspace:
        // context
        //     .read<AddWorkspaceCubit>()
        //     .setFlowStage(add_workspace_repo.FlowStage.info);
        content = AddWorkspaceFlow();
    }
    return ClipRRect(
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(10.0),
        topRight: const Radius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffefeef3),
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
    );
  }
}
