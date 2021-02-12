import 'package:flutter/material.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/models/member.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/removable_item.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberManagement extends StatefulWidget {
  @override
  _MemberManagementState createState() => _MemberManagementState();
}

class _MemberManagementState extends State<MemberManagement> {
  String _channelId;
  List<Member> _members = [];
  Member _heself;

  void _cancel() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<SheetBloc>().add(CloseSheet());
  }

  void _save() {
    FocusScope.of(context).requestFocus(new FocusNode());
    final ids = _members.ids;
    context.read<MemberCubit>().deleteMembers(
          channelId: _channelId,
          members: ids,
        );
    print('SAVE');
  }

  void _remove(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state is MembersLoaded) {
          _channelId = state.channelId;
          _members = state.members;
          _heself = _members.firstWhere(
            (m) => m.userId == ProfileBloc.userId,
            orElse: () => Member('no_id', 'no_id'),
          );
          _members.removeWhere((m) => m.userId == _heself.userId);
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
              itemCount: _members.length + 1,
              itemBuilder: (context, index) {
                return RemovableItem(
                  title: index == 0 ? _heself.email : _members[index].email,
                  removable: index != 0,
                  onRemove: () => _remove(index),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
