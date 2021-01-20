part of '../blocs/draft_bloc.dart';

abstract class DraftState extends Equatable {
  const DraftState();
}

class DraftInitial extends DraftState {
  @override
  List<Object> get props => [];
}

class DraftLoading extends DraftState {
  @override
  List<Object> get props => [];
}

class DraftLoaded extends DraftState {
  final String id;
  final DraftType type;
  final String draft;

  const DraftLoaded({
    @required this.id,
    @required this.type,
    @required this.draft,
  });

  @override
  List<Object> get props => [id, type, draft];
}

class DraftUpdated extends DraftState {
  final String id;
  final DraftType type;
  final String draft;

  const DraftUpdated({
    @required this.id,
    @required this.type,
    @required this.draft,
  });

  @override
  List<Object> get props => [id, type, draft];
}

class DraftSaving extends DraftState {
  @override
  List<Object> get props => [];
}

class DraftSaved extends DraftState {
  @override
  List<Object> get props => [];
}

class DraftError extends DraftState {
  final String message;

  const DraftError(this.message);

  @override
  List<Object> get props => [message];
}
