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

class WrongAuthCredentials extends AuthEvent {
  const WrongAuthCredentials();

  @override
  List<Object> get props => [];
}

class SetAuthData extends AuthEvent {
  final Map<String, String> authData;

  const SetAuthData(this.authData);

  @override
  List<Object> get props => [authData];
}

class ResetAuthentication extends AuthEvent {
  final String message;
  ResetAuthentication({this.message});

  @override
  List<Object> get props => [message];
}

class AuthInitialize extends AuthEvent {
  @override
  List<Object> get props => [];
}
