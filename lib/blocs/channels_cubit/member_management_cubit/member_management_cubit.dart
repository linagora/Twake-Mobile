import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/utils/extensions.dart';

class MemberManagementCubit extends Cubit<MemberManagementState> {
  final WorkspacesCubit workspacesCubit;

  MemberManagementCubit({required this.workspacesCubit}) : super(MemberManagementInitial());

  void getMembersFromIds(List<String> ids) async {
    emit(MemberManagementInProgress());

    final allMember = await workspacesCubit.fetchMembers(local: true);
    final channelMembers = allMember.where((member) => ids.contains(member.id)).toList();

    emit(MemberManagementNormalState(allMembers: channelMembers));
  }

  void searchMembers(String memberName) {
    if (memberName.isReallyEmpty) {
      emit(MemberManagementNormalState(allMembers: state.allMembers));
      return;
    }
    final searchKeyword = memberName.toLowerCase().trim();

    final allMembers = state.allMembers;
    final results = allMembers.where((member) {
      if (member.username.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.firstname != null &&
          member.firstname!.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.lastname != null &&
          member.lastname!.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.email.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      return false;
    }).toList();

    emit(MemberManagementSearchState(
        allMembers: state.allMembers,
        searchResults: results));
  }
}
