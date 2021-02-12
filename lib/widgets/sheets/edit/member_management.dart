import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_state.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/removable_text_field.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberManagement extends StatefulWidget {
  @override
  _MemberManagementState createState() => _MemberManagementState();
}

class _MemberManagementState extends State<MemberManagement> {
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
          editable: false,
        ),
        0);
  }

  void _cancel() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<SheetBloc>().add(CloseSheet());
  }

  void _save() {
    FocusScope.of(context).requestFocus(new FocusNode());
    // context.read<MemberCubit>().updateMembers(channelId: null, members: null)
    //   ..update(members: _members)
    //   ..setFlowStage(FlowStage.info);
    print('SAVE');
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
              title: 'Member management',
              leadingTitle: 'Cancel',
              leadingAction: () => _cancel(),
              trailingTitle: 'Save',
              trailingAction: () => _save(),
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