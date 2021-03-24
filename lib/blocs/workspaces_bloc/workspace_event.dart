import 'package:equatable/equatable.dart';

abstract class WorkspacesEvent extends Equatable {
  const WorkspacesEvent();
}

class ReloadWorkspaces extends WorkspacesEvent {
  // parent company id
  final String companyId;
  final bool forceFromApi;

  const ReloadWorkspaces(this.companyId, {this.forceFromApi = false});

  @override
  List<Object> get props => [companyId];
}

class ForceRefresh extends WorkspacesEvent {
  // parent company id
  const ForceRefresh();

  @override
  List<Object> get props => [];
}

class CheckForChange extends WorkspacesEvent {
  // parent company id
  final String companyId;

  const CheckForChange(this.companyId);

  @override
  List<Object> get props => [companyId];
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

  const ChangeSelectedWorkspace(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}

class RemoveWorkspace extends WorkspacesEvent {
  final String workspaceId;

  RemoveWorkspace(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}
