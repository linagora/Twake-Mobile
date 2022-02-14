import 'package:equatable/equatable.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';

abstract class JoiningState extends Equatable {

  const JoiningState();

  @override
  List<Object?> get props => [];
}

class JoiningStateInit extends JoiningState {

  const JoiningStateInit();

  @override
  List<Object?> get props => [];
}

class JoiningStateCheckingHost extends JoiningState {

  const JoiningStateCheckingHost();

  @override
  List<Object?> get props => [];
}

class JoiningWithDifferenceHost extends JoiningState {

  const JoiningWithDifferenceHost();

  @override
  List<Object?> get props => [];
}

class JoiningStateForceLogout extends JoiningState {

  const JoiningStateForceLogout();

  @override
  List<Object?> get props => [];
}

class JoiningCheckTokenStart extends JoiningState {

  const JoiningCheckTokenStart();

  @override
  List<Object?> get props => [];
}

class JoiningCheckTokenFinished extends JoiningState {
  final WorkspaceJoinResponse? joinResponse;

  const JoiningCheckTokenFinished({
    this.joinResponse,
  });

  @override
  List<Object?> get props => [joinResponse];
}

class InvitationJoinInit extends JoiningState {

  const InvitationJoinInit();

  @override
  List<Object?> get props => [];
}

class InvitationJoinSuccess extends JoiningState {
  final String requestedToken;
  final WorkspaceJoinResponse? joinResponse;
  final bool needCheckAuthentication;

  const InvitationJoinSuccess({
    required this.requestedToken,
    required this.needCheckAuthentication,
    this.joinResponse,
  });

  @override
  List<Object?> get props => [requestedToken, joinResponse, needCheckAuthentication];
}

class InvitationJoinFailed extends JoiningState {

  const InvitationJoinFailed();

  @override
  List<Object?> get props => [];
}
