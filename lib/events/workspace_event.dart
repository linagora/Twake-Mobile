import 'package:equatable/equatable.dart';

abstract class WorkspacesEvent extends Equatable {
  const WorkspacesEvent();
}

class LoadWorkspaces extends WorkspacesEvent {
  const LoadWorkspaces();
  @override
  List<Object> get props => [];
}

class ClearWorkspaces extends WorkspacesEvent {
  const ClearWorkspaces();
  @override
  List<Object> get props => [];
}

class LoadSingleWorkspace extends WorkspacesEvent {
  final String workspaceId;
  LoadSingleWorkspace(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}

class ChangeSelectedWorkspace extends WorkspacesEvent {
  final String workspaceId;
  ChangeSelectedWorkspace(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}
