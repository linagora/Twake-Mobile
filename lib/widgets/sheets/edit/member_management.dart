import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/models/member.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/removable_item.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberManagement extends StatefulWidget {
  @override
  _MemberManagementState createState() => _MemberManagementState();
}

class _MemberManagementState extends State<MemberManagement> {
  List<Member> _members = [];

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
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state is MembersLoaded) {
          _members = state.members;
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
            HintLine(text: '${_members.length} MEMBERS', isLarge: true),
            SizedBox(height: 8.0),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            ListView.builder(
              padding: EdgeInsets.only(top: 0),
              shrinkWrap: true,
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return RemovableItem(
                  title: member.id,
                  removable: index != 0,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
