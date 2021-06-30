part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();

  @override
  List<Object?> get props => const [];
}

class AuthenticationSuccess extends AuthenticationState {
  const AuthenticationSuccess();

  @override
  List<Object?> get props => const [];
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
  List<Object?> get props => const [];
}

class PostAuthenticationSyncInProgress extends AuthenticationState {
  final int progress;

  const PostAuthenticationSyncInProgress({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class PostAuthenticationSyncFailed extends AuthenticationState {
  const PostAuthenticationSyncFailed();

  @override
  List<Object?> get props => const [];
}

class PostAuthenticationSyncSuccess extends AuthenticationState {
  const PostAuthenticationSyncSuccess();

  @override
  List<Object?> get props => const [];
}
