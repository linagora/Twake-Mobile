import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_state.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/removable_text_field.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollaboratorsList extends StatefulWidget {
  @override
  _CollaboratorsListState createState() => _CollaboratorsListState();
}

class _CollaboratorsListState extends State<CollaboratorsList> {
  var _canInvite = true;
  List<Widget> _fields = [];
  List<String> _members = [];

  @override
  void initState() {
    super.initState();
    // First field init
    context.read<FieldsCubit>().add(
        RemovableTextField(
          key: UniqueKey(),
          index: 0,
          isLastOne: true,
        ),
        0);
  }

  void _return() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>()
      ..update(members: _members)
      ..setFlowStage(FlowStage.info);
  }

  void _invite() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>()
      ..update(members: _members)
      ..setFlowStage(FlowStage.info);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FieldsCubit, FieldsState>(
      listener: (context, state) {
        if (state is Updated) {
          _members = state.data.values.toList();
        }
      },
      builder: (context, state) {
        if (state is Added || state is Removed || state is Cleared) {
          _fields = state.fields;
        }
        return Column(
          children: [
            SheetTitleBar(
              title: 'Invite',
              leadingTitle: 'Back',
              leadingAction: () => _return(),
              trailingTitle: 'Send',
              trailingAction: () => _canInvite ? _invite() : null,
            ),
            SizedBox(height: 32.0),
            HintLine(text: 'ADD COLLABORATORS', isLarge: true),
            SizedBox(height: 8.0),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            ..._fields,
          ],
        );
      },
    );
  }
}