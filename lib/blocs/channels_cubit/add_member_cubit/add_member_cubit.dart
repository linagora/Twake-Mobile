import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/utils/extensions.dart';

class AddMemberCubit extends Cubit<AddMemberState> {
  final WorkspacesCubit workspacesCubit;

  AddMemberCubit({required this.workspacesCubit}) : super(AddMemberInitial());

  void fetchAllMembers() async {
    List<Account> members = await workspacesCubit.fetchMembers();
    emit(AddMemberInFrequentlyContacted(
      allMembers: members,
      selectedMembers: [],
      frequentlyContacted: [],
    ));
  }

  void searchMembers(String memberName) {
    if (memberName.isReallyEmpty) {
      emit(AddMemberInFrequentlyContacted(
        allMembers: state.allMembers,
        selectedMembers: [],
        frequentlyContacted: state.frequentlyContacted,
      ));
      return;
    }
    final searchKeyword = memberName.toLowerCase().trim();

    final allMembers = state.allMembers;
    final results = allMembers.where((member) {
      if (member.username.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.firstname != null && member.firstname!.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.lastname != null && member.lastname!.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      return false;
    }).toList();

    emit(AddMemberInSearch(
        allMembers: state.allMembers,
        searchResults: results,
        selectedMembers: state.selectedMembers,
        frequentlyContacted: state.frequentlyContacted));
  }

  void selectMember(Account member) {
    emit(AddMemberInFrequentlyContacted(
      allMembers: state.allMembers,
      selectedMembers: state.selectedMembers..add(member),
      frequentlyContacted: [],
    ));
  }
}
