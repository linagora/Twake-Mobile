part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class AuthenticationValidation extends AuthenticationState {
  const AuthenticationValidation();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();

  @override
  List<Object?> get props => [];
}

class AuthenticationSuccess extends AuthenticationState {
  const AuthenticationSuccess();

  @override
  List<Object?> get props => [];
}

class AuthenticationFailure extends AuthenticationState {
  const AuthenticationFailure();

  @override
  List<Object?> get props => throw UnimplementedError();
}

class AuthenticationInProgress extends AuthenticationState {
  const AuthenticationInProgress();

  @override
  List<Object?> get props => [];
}
