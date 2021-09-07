import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_state.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/utils/extensions.dart';

class MemberManagementCubit extends Cubit<MemberManagementState> {
  final ChannelsCubit channelsCubit;

  MemberManagementCubit({required this.channelsCubit})
      : super(MemberManagementInitial());

  void getMembersFromIds({required Channel channel}) async {
    emit(MemberManagementInProgress());

    final members = await channelsCubit.fetchMembers(channel: channel);

    emit(MemberManagementNormalState(allMembers: members));
  }

  void updateMemberList(List<Account> members) {
    emit(MemberManagementNormalState(allMembers: members));
  }

  void newMembersAdded(List<Account> newMembers) {
    final updatedList = List<Account>.from(state.allMembers)
      ..addAll(newMembers);
    emit(MemberManagementNormalState(allMembers: updatedList));
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
      if (member.fullName.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      if (member.email.toLowerCase().contains(searchKeyword)) {
        return true;
      }
      return false;
    }).toList();

    emit(MemberManagementSearchState(
      allMembers: state.allMembers,
      searchResults: results,
    ));
  }
}
