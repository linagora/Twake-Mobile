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

class AuthenticationSuccess extends AuthenticationState {
  final WorkspaceJoinResponse? magicLinkJoinResponse;
  const AuthenticationSuccess({this.magicLinkJoinResponse});

  @override
  List<Object?> get props => [magicLinkJoinResponse];
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
  final WorkspaceJoinResponse? magicLinkJoinResponse;

  const PostAuthenticationSyncSuccess({this.magicLinkJoinResponse});

  @override
  List<Object?> get props => [magicLinkJoinResponse];
}

// --------- MAGIC LINK

class AuthenticationInvitationPending extends AuthenticationState {
  final WorkspaceJoinResponse? magicLinkJoinResponse;
  final String? requestedToken;
  const AuthenticationInvitationPending({this.magicLinkJoinResponse, this.requestedToken});

  @override
  List<Object?> get props => [magicLinkJoinResponse, requestedToken];
}

class InvitationJoinCheckingInit extends AuthenticationState {
  const InvitationJoinCheckingInit();

  @override
  List<Object?> get props => const [];
}

class InvitationJoinCheckingTokenFinished extends AuthenticationState {
  final String requestedToken;
  final WorkspaceJoinResponse? joinResponse;
  final bool? isDifferenceServer;

  const InvitationJoinCheckingTokenFinished({
    required this.requestedToken,
    this.joinResponse,
    this.isDifferenceServer,
  });

  @override
  List<Object?> get props => [joinResponse, requestedToken, isDifferenceServer];
}

class InvitationJoinInit extends AuthenticationState {
  const InvitationJoinInit();

  @override
  List<Object?> get props => const [];
}

class InvitationJoinSuccess extends AuthenticationState {
  final String requestedToken;
  final WorkspaceJoinResponse? joinResponse;
  final bool needCheckAuthentication;
  const InvitationJoinSuccess({required this.requestedToken, required this.needCheckAuthentication, this.joinResponse});

  @override
  List<Object?> get props => [requestedToken, joinResponse, needCheckAuthentication];
}

class InvitationJoinFailed extends AuthenticationState {
  const InvitationJoinFailed();

  @override
  List<Object?> get props => [];
}
