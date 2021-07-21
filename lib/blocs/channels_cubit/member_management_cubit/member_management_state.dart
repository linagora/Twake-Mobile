import 'package:equatable/equatable.dart';
import 'package:twake/models/account/account.dart';

abstract class MemberManagementState with EquatableMixin {
  final List<Account> allMembers;

  const MemberManagementState({this.allMembers = const [],});

  @override
  List<Object?> get props => [allMembers];
}

class MemberManagementInitial extends MemberManagementState {
  const MemberManagementInitial();
}

class MemberManagementInProgress extends MemberManagementState {
  const MemberManagementInProgress();
}

class MemberManagementNormalState extends MemberManagementState {
  const MemberManagementNormalState({required List<Account> allMembers})
      : super(allMembers: allMembers);

  @override
  List<Object?> get props => super.props;
}

class MemberManagementSearchState extends MemberManagementState {
  final List<Account> searchResults;

  const MemberManagementSearchState(
      {required List<Account> allMembers, required this.searchResults})
      : super(allMembers: allMembers);

  @override
  List<Object?> get props => [...super.props, searchResults];
}
