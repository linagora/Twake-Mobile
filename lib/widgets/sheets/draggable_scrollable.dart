/* import 'package:flutter/material.dart';
import 'package:twake/pages/profile/profile_flow.dart';
import 'package:twake/pages/workspaces/workspaces.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/sheets/add/add_channel_flow.dart';
import 'package:twake/widgets/sheets/add/add_direct_flow.dart';
import 'package:twake/widgets/sheets/add/add_workspace_flow.dart';
import 'package:twake/widgets/sheets/edit/edit_channel_flow.dart';

class DraggableScrollable extends StatelessWidget {
  final SheetFlow? flow;

  const DraggableScrollable({Key? key, this.flow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('Current flow: $flow');
    Widget content = AddChannelFlow();
    switch (flow) {
      case SheetFlow.addChannel:
        content = AddChannelFlow();
        break;
      case SheetFlow.editChannel:
        content = EditChannelFlow();
        break;
      case SheetFlow.direct:
        content = AddDirectFlow();
        break;
      case SheetFlow.addWorkspace:
        content = AddWorkspaceFlow();
        break;
      case SheetFlow.selectWorkspace:
        content = Workspaces();
        break;
      case SheetFlow.profile:
        content = ProfileFlow();
        break;
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
        child: content,
      ),
    );
  }
}
 */
