import 'package:equatable/equatable.dart';
import 'package:twake/models/workspace.dart';

abstract class WorkspaceState extends Equatable {
  final List<Workspace?>? workspaces;
  final Workspace? selected;

  const WorkspaceState({this.workspaces, this.selected});

  @override
  List<Object?> get props => [workspaces, selected];
}

class WorkspacesLoaded extends WorkspaceState {
  final List<Workspace?>? workspaces;
  final Workspace? selected;
  final String? force;

  const WorkspacesLoaded({
    this.workspaces,
    this.force,
    this.selected,
  });

  @override
  List<Object?> get props => [workspaces, selected, force];
}

class WorkspaceSelected extends WorkspacesLoaded {
  const WorkspaceSelected({
    workspaces,
    selected,
  }) : super(workspaces: workspaces, selected: selected);
}

class WorkspacesLoading extends WorkspaceState {
  final String? companyId;

  const WorkspacesLoading({this.companyId});

  @override
  List<Object?> get props => [companyId];
}

class WorkspacesEmpty extends WorkspaceState {
  const WorkspacesEmpty();

  @override
  List<Object> get props => [];
}
