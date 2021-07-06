import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/utils/extensions.dart';

class AddMemberCubit extends Cubit<AddMemberState> {
  final WorkspacesCubit workspacesCubit;

  AddMemberCubit({required this.workspacesCubit}) : super(AddMemberInitial());

  void fetchAllMembers({List<Account>? selectedMembers}) async {
    if (selectedMembers != null) {
      emit(AddMemberInFrequentlyContacted(
        allMembers: state.allMembers,
        selectedMembers: selectedMembers,
        frequentlyContacted: state.frequentlyContacted,
      ));
    }

    List<Account> members = await workspacesCubit.fetchMembers(local: true);
    emit(AddMemberInFrequentlyContacted(
      allMembers: members,
      selectedMembers: state.selectedMembers,
      frequentlyContacted: state.frequentlyContacted,
    ));
  }

  void searchMembers(String memberName) {
    if (memberName.isReallyEmpty) {
      emit(AddMemberInFrequentlyContacted(
        allMembers: state.allMembers,
        selectedMembers: state.selectedMembers,
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

    emit(AddMemberInSearch(
        allMembers: state.allMembers,
        searchResults: results,
        selectedMembers: state.selectedMembers,
        frequentlyContacted: state.frequentlyContacted));
  }

  void selectMember(Account member) {
    List<Account> newList = List.from(state.selectedMembers);
    newList.add(member);
    emit(AddMemberInFrequentlyContacted(
      allMembers: state.allMembers,
      selectedMembers: newList,
      frequentlyContacted: state.frequentlyContacted,
    ));
  }

  void removeMember(Account member) {
    List<Account> newList = List.from(state.selectedMembers);
    newList.removeWhere((element) => element.id == member.id);

    if (state is AddMemberInFrequentlyContacted) {
      emit(AddMemberInFrequentlyContacted(
        allMembers: state.allMembers,
        selectedMembers: newList,
        frequentlyContacted: state.frequentlyContacted,
      ));
    } else {
      emit(AddMemberInSearch(
          allMembers: state.allMembers,
          searchResults: state.searchResults,
          selectedMembers: newList,
          frequentlyContacted: state.frequentlyContacted));
    }
  }
}
