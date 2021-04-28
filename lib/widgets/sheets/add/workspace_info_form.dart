import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_state.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_state.dart' as field_state;
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/common/button_field.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';

import '../removable_text_field.dart';

class WorkspaceInfoForm extends StatefulWidget {
  @override
  _WorkspaceInfoFormState createState() => _WorkspaceInfoFormState();
}

class _WorkspaceInfoFormState extends State<WorkspaceInfoForm> {
  final _workspaceNameController = TextEditingController();
  final _workspaceNameFocusNode = FocusNode();

  var _canCreate = false;

  // A workaround for unintended redirects when panel is closed.
  var _shouldRedirect = false;
  var _collaborators = <String>[];
  var _workspaceId = '';

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
          members:
              collaborators, //['31a4a6a4-54f2-11eb-a382-0242ac120004'];]//_collaborators,['senjertomat@yandex.ru'],
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SheetBloc, SheetState>(
      listener: (context, state) {
        if (state is SheetShouldClear) {
          _workspaceNameController.clear();
          _collaborators = <String>[];
          _workspaceId = '';
          _batchUpdateState(
            name: '',
            collaborators: _collaborators,
          );
          FocusScope.of(context).requestFocus(FocusNode());
          context.read<AddWorkspaceCubit>().clear();
        }
      },
      child: BlocConsumer<AddWorkspaceCubit, AddWorkspaceState>(
        listener: (context, state) {
          if (state is Created) {
            _workspaceId = state.workspaceId;
            // Reload workspaces
            context.read<WorkspacesBloc>().add(
                  ReloadWorkspaces(
                    ProfileBloc.selectedCompanyId,
                    forceFromApi: true,
                  ),
                );
            _shouldRedirect = true;
          } else if (state is Error) {
            // Show an error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        buildWhen: (_, current) => current is Updated || current is Creation,
        builder: (context, state) {
          bool createIsBlocked = state is Creation;
          if (state is Updated) {
            _collaborators = state.repository?.members;

            print('Collaborators: $_collaborators');
          }
          return BlocListener<WorkspacesBloc, WorkspaceState>(
            listener: (context, state) {
              // print('Workspaces status: $state');
              if (state is WorkspacesLoaded) {
                // Redirect user to created workspace.
                if (_shouldRedirect) {
                  _shouldRedirect = false;
                  selectWorkspace(context, _workspaceId);
                  // Close sheet
                  context.read<SheetBloc>().add(CloseSheet());
                  // Clear sheet
                  context.read<SheetBloc>().add(ClearSheet());
                }
              }
            },
            child: Column(
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
                      : () => context.read<AddWorkspaceCubit>().create(),
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
                      maxLength: 30,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                HintLine(text: 'Please provide a name for your new workspace'),
                SizedBox(height: 8),
                BlocBuilder<FieldsCubit, field_state.FieldsState>(
                    builder: (context, state) => CollaboratorsButton(
                        count: context
                                .read<FieldsCubit>()
                                .getAll()
                                .whereType<RemovableTextField>()
                                .length -
                            1)),
                SizedBox(height: 8),
                HintLine(text: 'Invite collaborators via email'),
              ],
            ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
      child: ButtonField(
        title: 'Invited collaborators',
        trailingTitle: count > 0 ? '$count' : 'Add',
        hasArrow: count > 0,
        onTap: () => context
            .read<AddWorkspaceCubit>()
            .setFlowStage(FlowStage.collaborators),
      ),
    );
  }
}
