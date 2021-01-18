part of '../blocs/draft_bloc.dart';

abstract class DraftEvent extends Equatable {
  const DraftEvent();
}

class LoadDraft extends DraftEvent {
  final String id;
  final String type;

  LoadDraft({@required this.id, @required this.type});

  @override
  List<Object> get props => [id, type];
}

class DraftLoading extends DraftEvent {
  @override
  List<Object> get props => [];
}

class DraftLoaded extends DraftEvent {
  final String draft;

  DraftLoaded(this.draft);

  @override
  List<Object> get props => [draft];
}

class SaveDraft extends DraftEvent {
  final String id;
  final String type;
  final String draft;

  SaveDraft({
    @required this.id,
    @required this.type,
    @required this.draft,
  });

  @override
  List<Object> get props => [id, type, draft];
}

class ResetDraft extends DraftEvent {
  final String id;
  final String type;

  ResetDraft({@required this.id, @required this.type});

  @override
  List<Object> get props => [id, type];
}

class DraftError extends DraftEvent {
  final String message;

  DraftError(this.message);

  @override
  List<Object> get props => [message];
}
