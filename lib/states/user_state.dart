import 'package:equatable/equatable.dart';

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
