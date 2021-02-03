import 'package:flutter/material.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/sheets/add_channel_flow.dart';
import 'package:twake/widgets/sheets/add_direct_flow.dart';
import 'package:twake/widgets/sheets/add_workspace_flow.dart';

class DraggableScrollable extends StatelessWidget {
  final SheetFlow flow;

  const DraggableScrollable({Key key, this.flow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = AddChannelFlow();
    switch (flow) {
      case SheetFlow.channel:
        content = AddChannelFlow();
        break;
      case SheetFlow.direct:
        content = AddDirectFlow();
        break;
      case SheetFlow.workspace:
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
