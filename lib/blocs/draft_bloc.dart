import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:twake/repositories/draft_repository.dart';

part '../events/draft_event.dart';
part '../states/draft_state.dart';

class DraftBloc extends Bloc<DraftEvent, DraftState> {
  final DraftRepository repository;

  DraftBloc(this.repository) : super(DraftInitial());

  @override
  Stream<DraftState> mapEventToState(
    DraftEvent event,
  ) async* {
    if (event is LoadDraft) {
      yield DraftLoading();
      final draft = await repository.load(id: event.id, type: event.type);
      yield DraftLoaded(id: event.id, draft: draft);
    } else if (event is SaveDraft) {
      yield DraftSaving();
      try {
        await repository.save(id: event.id, type: event.type, draft: event.draft);
        DraftSaved();
      } on Exception {
        DraftError('Draft saving failure.');
      }
    } else if (event is ResetDraft) {
      yield DraftSaving();
      try {
        await repository.remove(id: event.id, type: event.type);
        DraftSaved();
      } on Exception {
        yield DraftError('Draft reset failure');
      }
    }
  }
}
