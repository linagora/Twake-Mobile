import 'package:equatable/equatable.dart';
import 'package:twake/services/init.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitializing extends AuthState {
  const AuthInitializing();

  @override
  List<Object> get props => [];
}

class Unauthenticated extends AuthState {
  final String message;
  final String username;
  final String password;

  const Unauthenticated({this.message, this.username, this.password});

  @override
  List<Object> get props => [username, password];
}

class WrongCredentials extends Unauthenticated {
  const WrongCredentials({String username, String password})
      : super(username: username, password: password);

  @override
  List<Object> get props => [];
}

class Authenticating extends AuthState {
  const Authenticating();

  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  final InitData initData;

  const Authenticated(this.initData);

  @override
  List<Object> get props => [];
}

class Registration extends AuthState {
  final String link;

  const Registration(this.link);

  @override
  List<Object> get props => [link];
}

class PasswordReset extends AuthState {
  final String link;

  const PasswordReset(this.link);

  @override
  List<Object> get props => [link];
}

class AuthenticationError extends Unauthenticated {
  const AuthenticationError({String username, String password})
      : super(username: username, password: password);

  @override
  List<Object> get props => [];
}

class HostValidated extends AuthState {
  final String host;

  const HostValidated(this.host);

  @override
  List<Object> get props => [host];
}

class HostInvalid extends AuthState {
  final String host;

  const HostInvalid(this.host);

  @override
  List<Object> get props => [host];
}
