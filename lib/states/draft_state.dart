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
  final String draft;

  const DraftLoaded(this.draft);

  @override
  List<Object> get props => [draft];
}

class DraftError extends DraftState {
  final String message;

  const DraftError(this.message);

  @override
  List<Object> get props => [message];
}
