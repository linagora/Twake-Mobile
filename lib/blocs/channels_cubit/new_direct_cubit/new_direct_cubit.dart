import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_state.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/utils/extensions.dart';

class NewDirectCubit extends Cubit<NewDirectState> {
  final WorkspacesCubit workspacesCubit;
  final DirectsCubit directsCubit;
  final AccountCubit accountCubit;

  NewDirectCubit({
    required this.workspacesCubit,
    required this.directsCubit,
    required this.accountCubit,
  }) : super(NewDirectInitial());

  void fetchAllMember() async {
    emit(NewDirectInProgress());

    final members = await workspacesCubit.fetchMembers();
    final recentChats = await _fetchRecentChats();

    emit(NewDirectNormalState(
      members: members,
      recentChats: recentChats,
    ));
  }

  void searchMembers(String memberName) {
    if (memberName.isReallyEmpty) {
      emit(NewDirectNormalState(
          members: state.members, recentChats: state.recentChats));
      return;
    }
    final searchKeyword = memberName.toLowerCase().trim();

    final allMembers = state.members;
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

    emit(NewDirectFoundMemberState(
        foundMembers: results,
        members: state.members,
        recentChats: state.recentChats));
  }

  Future<List<Account>> _fetchRecentChats() async {
    List<Account> recentChats = [];

    if (directsCubit.state is ChannelsLoadedSuccess) {
      final directs = (directsCubit.state as ChannelsLoadedSuccess).channels;
      for (final direct in directs.where((d) => d.members.length < 2)) {
        final account =
            await accountCubit.fetchStateless(userId: direct.members.first);
        recentChats.add(account);
      }
    }
    return recentChats;
  }
}
