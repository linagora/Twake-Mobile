part of 'add_workspace_cubit.dart';

abstract class AddWorkspaceState extends Equatable {
  const AddWorkspaceState();
}

class AddWorkspaceInitial extends AddWorkspaceState {
  @override
  List<Object> get props => [];
}

class Updated extends AddWorkspaceState {
  final AddWorkspaceRepository repository;

  Updated(this.repository);

  @override
  List<Object> get props => [repository];
}

class Creation extends AddWorkspaceState {
  @override
  List<Object> get props => [];
}

class Created extends AddWorkspaceState {
  final String workspaceId;

  Created(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}

class Error extends AddWorkspaceState {
  final String message;

  Error(this.message);

  @override
  List<Object> get props => [message];
}

class MembersUpdated extends AddWorkspaceState {
  final String workspaceId;
  final List<String> members;

  MembersUpdated({
    @required this.workspaceId,
    @required this.members,
  });

  @override
  List<Object> get props => [workspaceId, members];
}
