import 'package:equatable/equatable.dart';
import 'package:twake/models/workspace/workspace.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspacesInitial extends WorkspaceState {
  const WorkspacesInitial();

  @override
  List<Object?> get props => [];
}

class WorkspacesLoadInProgress extends WorkspaceState {
  const WorkspacesLoadInProgress();

  @override
  List<Object?> get props => [];
}

class WorkspacesLoadSuccess extends WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? selected;

  WorkspacesLoadSuccess({required this.workspaces, this.selected});

  @override
  List<Object?> get props => super.props;
}
