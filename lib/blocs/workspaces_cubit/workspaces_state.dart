import 'package:equatable/equatable.dart';
import 'package:twake/models/workspace/workspace.dart';

abstract class WorkspacesState extends Equatable {
  const WorkspacesState();

  @override
  List<Object?> get props => [];
}

class WorkspacesInitial extends WorkspacesState {
  const WorkspacesInitial();

  @override
  List<Object?> get props => [];
}

class WorkspacesLoadInProgress extends WorkspacesState {
  const WorkspacesLoadInProgress();

  @override
  List<Object?> get props => [];
}

class WorkspacesLoadSuccess extends WorkspacesState {
  final List<Workspace> workspaces;
  final Workspace? selected;

  WorkspacesLoadSuccess({required this.workspaces, this.selected});

  @override
  List<Object?> get props => super.props;
}
