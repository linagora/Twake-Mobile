import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitializing extends AuthState {
  const AuthInitializing();
  @override
  List<Object> get props => [];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
  @override
  List<Object> get props => [];
}

class Authenticating extends AuthState {
  const Authenticating();
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  const Authenticated();
  @override
  List<Object> get props => [];
}

class AuthenticationError extends AuthState {
  const AuthenticationError();
  @override
  List<Object> get props => [];
}
