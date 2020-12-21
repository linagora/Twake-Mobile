import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class Authenticate extends AuthEvent {
  final String username;
  final String password;

  const Authenticate(this.username, this.password);

  @override
  List<Object> get props => [
        username,
        password,
      ];
}

class ResetAuthentication extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AuthInitialize extends AuthEvent {
  @override
  List<Object> get props => [];
}
