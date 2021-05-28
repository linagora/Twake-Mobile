import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/user.dart';

abstract class MentionState extends Equatable {
  const MentionState();
}

class MentionsEmpty extends MentionState {
  const MentionsEmpty();

  @override
  List<Object> get props => [];
}

class MentionableUsersLoaded extends MentionState {
  final List<User> users;

  const MentionableUsersLoaded({required this.users});

  @override
  List<Object> get props => [users];
}
