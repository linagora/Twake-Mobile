import 'package:equatable/equatable.dart';
import 'package:twake/models/account/account.dart';

abstract class NewDirectState with EquatableMixin {
  final Map<String, Account> recentChats;
  final List<Account> members;

  const NewDirectState({
    this.recentChats = const {},
    this.members = const [],
  });

  @override
  List<Object?> get props => [recentChats, members];
}

class NewDirectInitial extends NewDirectState {
  @override
  List<Object?> get props => [];
}

class NewDirectInProgress extends NewDirectState {
  @override
  List<Object?> get props => [];
}

class NewDirectNormalState extends NewDirectState {
  const NewDirectNormalState({
    required List<Account> members,
    required Map<String, Account> recentChats,
  }) : super(members: members, recentChats: recentChats);

  @override
  List<Object?> get props => super.props;
}

class NewDirectFoundMemberState extends NewDirectState {
  final List<Account> foundMembers;

  const NewDirectFoundMemberState({
    required this.foundMembers,
    required List<Account> members,
    required Map<String, Account> recentChats,
  }) : super(members: members, recentChats: recentChats);

  @override
  List<Object?> get props => [foundMembers, ...super.props];
}
