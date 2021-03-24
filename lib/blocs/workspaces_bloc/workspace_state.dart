import 'package:equatable/equatable.dart';
import 'package:twake/models/workspace.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();
}

class WorkspacesLoaded extends WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace selected;
  final String force;

  const WorkspacesLoaded({
    this.workspaces,
    this.force,
    this.selected,
  });
  @override
  List<Object> get props => [workspaces, selected, force];
}

class WorkspaceSelected extends WorkspacesLoaded {
  const WorkspaceSelected({
    workspaces,
    selected,
  }) : super(workspaces: workspaces, selected: selected);
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
