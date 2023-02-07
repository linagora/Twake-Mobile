part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();

  @override
  List<Object?> get props => const [];
}

class LogoutInProgress extends AuthenticationState {
  const LogoutInProgress();

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

class PostAuthenticationNoCompanyFound extends AuthenticationState {
  final WorkspaceJoinResponse? magicLinkJoinResponse;

  const PostAuthenticationNoCompanyFound({this.magicLinkJoinResponse});

  @override
  List<Object?> get props => [magicLinkJoinResponse];
}

class PostAuthenticationSyncFailedSomeServices extends AuthenticationState {
  final SyncFailedSource syncFailedSource;
  final WorkspaceJoinResponse? magicLinkJoinResponse;

  const PostAuthenticationSyncFailedSomeServices({
    required this.syncFailedSource,
    this.magicLinkJoinResponse,
  });

  @override
  List<Object?> get props => [syncFailedSource, magicLinkJoinResponse];
}

// --------- MAGIC LINK

class AuthenticationInvitationPending extends AuthenticationState {
  final WorkspaceJoinResponse? magicLinkJoinResponse;
  final String? requestedToken;

  const AuthenticationInvitationPending({
    this.magicLinkJoinResponse,
    this.requestedToken,
  });

  @override
  List<Object?> get props => [magicLinkJoinResponse, requestedToken];
}

class InvitationJoinCheckingInit extends AuthenticationState {
  const InvitationJoinCheckingInit();

  @override
  List<Object?> get props => const [];
}

class JoiningMagicLinkState extends AuthenticationState {
  final String requestedToken;
  final String incomingHost;

  const JoiningMagicLinkState({
    required this.requestedToken,
    required this.incomingHost,
  });

  @override
  List<Object> get props => [requestedToken, incomingHost];
}
