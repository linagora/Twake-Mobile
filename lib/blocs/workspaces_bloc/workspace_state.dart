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
  List<Object> get props => [workspaces, selected];
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
