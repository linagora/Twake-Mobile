import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part '../events/draft_event.dart';
part '../states/draft_state.dart';

class DraftBloc extends Bloc<DraftEvent, DraftState> {
  DraftBloc() : super(DraftInitial());

  @override
  Stream<DraftState> mapEventToState(
    DraftEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
