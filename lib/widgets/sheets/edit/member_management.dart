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
  List<Member> _toDelete = [];

  void _cancel() {
    setState(() {
      _toDelete.clear();
    });
    context.read<SheetBloc>().add(CloseSheet());
  }

  void _save() {
    FocusScope.of(context).requestFocus(new FocusNode());
    final ids = _toDelete.ids;
    print('IDS to DELETE: $ids');
    print('EMAILS to DELETE: ${_toDelete.map((e) => e.email)}');
    context.read<MemberCubit>().deleteMembers(
          channelId: _channelId,
          members: ids,
        );
    print('SAVE');
  }

  void _remove(int index) {
    setState(() {
      _toDelete.add(_members[index]);
      _members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberCubit, MemberState>(
      listener: (_, current) {
        if (current is MembersDeleted) {
          _cancel();
        }
      },
      buildWhen: (_, current) => current is MembersLoaded,
      builder: (context, state) {
        Member _himself;

        if (state is MembersLoaded) {
          _channelId = state.channelId;
          _members = state.members;

          print(_members.map((e) => e.email));

          _himself ??= _members.firstWhere(
            (m) => m.id == ProfileBloc.userId,
            orElse: () => Member('no_id', 'no_id', email: 'email unknown'),
          );
          _members.removeWhere((m) => m.userId == _himself.userId);
          _members.insert(0, _himself);

          print(_members.map((e) => e.email));
          print(_members.map((e) => e.userId));
          print(ProfileBloc.userId);
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
                return RemovableItem(
                  key: UniqueKey(),
                  title: _members[index].email,
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
