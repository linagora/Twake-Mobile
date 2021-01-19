part of '../blocs/draft_bloc.dart';

abstract class DraftEvent extends Equatable {
  const DraftEvent();
}

class LoadDraft extends DraftEvent {
  final String id;
  final DraftType type;

  const LoadDraft({@required this.id, @required this.type});

  @override
  List<Object> get props => [id, type];
}

class SaveDraft extends DraftEvent {
  final String id;
  final DraftType type;
  final String draft;

  const SaveDraft({
    @required this.id,
    @required this.type,
    @required this.draft,
  });

  @override
  List<Object> get props => [id, type, draft];
}

class ResetDraft extends DraftEvent {
  final String id;
  final DraftType type;

  const ResetDraft({@required this.id, @required this.type});

  @override
  List<Object> get props => [id, type];
}
