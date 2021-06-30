part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
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
  final String username;
  final String password;
  const AuthenticationFailure({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthenticationInProgress extends AuthenticationState {
  const AuthenticationInProgress();

  @override
  List<Object?> get props => [];
}

class PostAuthenticationSyncInProgress extends AuthenticationState {
  const PostAuthenticationSyncInProgress();

  @override
  List<Object?> get props => [];
}

class PostAuthenticationSyncFailed extends AuthenticationFailure {
  const PostAuthenticationSyncFailed({
    required String username,
    required String password,
  }) : super(username: username, password: password);

  @override
  List<Object?> get props => [username, password];
}
