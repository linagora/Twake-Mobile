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
      
    } else if (event is SaveDraft) {

    } else if (event is ResetDraft) {

    }
  }
}
