import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_state.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/utils/extensions.dart';

class AddMemberCubit extends Cubit<AddMemberState> {
  final WorkspacesCubit workspacesCubit;
  final ChannelsCubit channelsCubit;

  AddMemberCubit({required this.workspacesCubit, required this.channelsCubit})
      : super(AddMemberInitial());

  void fetchAllMembers({List<Account>? selectedMembers}) async {
    List<Account> members = await workspacesCubit.fetchMembers(local: true);
    emit(AddMemberInFrequentlyContacted(
      allMembers: members,
      selectedMembers: selectedMembers ?? state.selectedMembers,
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
      if (member.firstName != null &&
          member.firstName!.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.lastName != null &&
          member.lastName!.toLowerCase().contains(searchKeyword)) {
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

  Future<List<Account>> addMembersToChannel(
      Channel currentChannel, List<Account> newMembers) async {
    emit(AddMemberInProgress());

    final currentSet = Set.from(currentChannel.members);
    final newMemberSet = Set.from(newMembers.map((e) => e.id));
    // take new member ids to add only
    final idsToAdd = List<String>.from(newMemberSet.difference(currentSet));

    if (idsToAdd.isEmpty) {
      return <Account>[];
    }

    final result = await channelsCubit.addMembers(
        channel: currentChannel, usersToAdd: idsToAdd);

    if (result) {
      return newMembers
          .where((element) => idsToAdd.contains(element.id))
          .toList();
    }
    return <Account>[];
  }
}
