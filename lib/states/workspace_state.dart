import 'package:equatable/equatable.dart';
import 'package:twake/models/workspace.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();
}

class WorkspacesLoaded extends WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace selected;

  const WorkspacesLoaded({
    this.workspaces,
    this.selected,
  });
  @override
  // TODO: implement props
  List<Object> get props => [workspaces];
}

class WorkspacesLoading extends WorkspaceState {
  const WorkspacesLoading();
  @override
  List<Object> get props => [];
}

class WorkspacesEmpty extends WorkspaceState {
  const WorkspacesEmpty();
  @override
  List<Object> get props => [];
}
