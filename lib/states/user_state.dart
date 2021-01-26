import 'package:equatable/equatable.dart';
import 'package:twake/models/user.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class UserLoading extends UserState {
  const UserLoading();

  @override
  List<Object> get props => [];
}

class UserReady extends UserState {
  final String thumbnail;
  final String username;
  final String firstName;
  final String lastName;

  const UserReady({
    this.thumbnail,
    this.username,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object> get props => [username];
}

class MultipleUsersLoading extends UserState {
  const MultipleUsersLoading();

  @override
  List<Object> get props => [];
}

class MultipleUsersLoaded extends UserState {
  final List<User> users;

  MultipleUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object> get props => [message];
}
