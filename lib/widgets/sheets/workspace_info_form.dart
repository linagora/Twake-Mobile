import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/participants_widget.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';

class WorkspaceInfoForm extends StatefulWidget {
  @override
  _WorkspaceInfoFormState createState() => _WorkspaceInfoFormState();
}

class _WorkspaceInfoFormState extends State<WorkspaceInfoForm> {
  final _workspaceNameController = TextEditingController();
  final _workspaceNameFocusNode = FocusNode();

  var _canCreate = false;
  var _collaborators = <String>[];

  @override
  void initState() {
    super.initState();

    _workspaceNameController.addListener(() {
      final workspaceName = _workspaceNameController.text;
      _batchUpdateState(name: workspaceName);
      if (workspaceName.isNotReallyEmpty && !_canCreate) {
        setState(() {
          _canCreate = true;
        });
      } else if (workspaceName.isReallyEmpty && _canCreate) {
        setState(() {
          _canCreate = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _workspaceNameController.dispose();
    _workspaceNameFocusNode.dispose();
    super.dispose();
  }

  void _batchUpdateState({
    String name,
    List<String> collaborators,
  }) {
    context.read<AddWorkspaceCubit>().update(
          name: name ?? _workspaceNameController.text,
          members: collaborators ?? _collaborators,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SheetBloc, SheetState>(
      listener: (context, state) {
        if (state is SheetShouldClear) {
          _workspaceNameController.clear();
          FocusScope.of(context).requestFocus(new FocusNode());
          context.read<AddWorkspaceCubit>().clear();
        }
      },
      child: BlocConsumer<AddWorkspaceCubit, AddWorkspaceState>(
        listener: (context, state) {
          if (state is Created) {
            if (_collaborators.length != 0) {
              context.read<AddWorkspaceCubit>().updateMembers(
                    workspaceId: state.workspaceId,
                    members: _collaborators,
                  );
            }
            // Reload workspaces
            context
                .read<WorkspacesBloc>()
                .add(ReloadWorkspaces(ProfileBloc.selectedCompany));
            // Close sheet
            context.read<SheetBloc>().add(CloseSheet());
            // Clear sheet
            context.read<SheetBloc>().add(ClearSheet());
            // Redirect user to created workspace
            if (_collaborators.length == 0) {
              String workspaceId = state.workspaceId;
              selectWorkspace(context, workspaceId);
            }
          } else if (state is MembersUpdated) {
            String workspaceId = state.workspaceId;
            selectWorkspace(context, workspaceId);
          } else if (state is Error) {
            // Show an error
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              duration: Duration(seconds: 2),
            ));
          }
        },
        buildWhen: (_, current) => current is Updated || current is Creation,
        builder: (context, state) {
          bool createIsBlocked = state is Creation;
          if (state is Updated) {
            _collaborators = state.repository?.members;
          }
          return Column(
            children: [
              SheetTitleBar(
                title: 'New Workspace',
                leadingTitle: 'Cancel',
                leadingAction: () {
                  context.read<SheetBloc>().add(CloseSheet());
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                trailingTitle: 'Create',
                trailingAction: createIsBlocked || !_canCreate
                    ? null
                    : () => context
                        .read<AddWorkspaceCubit>()
                        .create(name: _workspaceNameController.text),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  color: Colors.white,
                  child: SheetTextField(
                    hint: 'Workspace name',
                    controller: _workspaceNameController,
                    focusNode: _workspaceNameFocusNode,
                  ),
                ),
              ),
              SizedBox(height: 8),
              HintLine(text: 'Please provide a name for your new workspace'),
              SizedBox(height: 8),
              CollaboratorsButton(count: _collaborators.length),
              SizedBox(height: 8),
              HintLine(text: 'Invite collaborators via email'),
            ],
          );
        },
      ),
    );
  }
}

class CollaboratorsButton extends StatelessWidget {
  final int count;

  const CollaboratorsButton({Key key, this.count = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<AddWorkspaceCubit>()
          .setFlowStage(FlowStage.collaborators),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
        child: ParticipantsWidget(
          title: 'Invited collaborators',
          trailingWidget: count > 0
              ? Row(
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff837cfe),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.forward,
                      color: Color(0xff837cfe),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 9.0),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff837cfe),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
