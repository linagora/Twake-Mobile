import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part '../events/sheet_event.dart';
part '../states/sheet_state.dart';

enum SheetFlow {
  channel,
  direct,
}

class SheetBloc extends Bloc<SheetEvent, SheetState> {
  final SheetFlow flow;
  SheetBloc(this.flow) : super(SheetInitial(flow: flow));

  @override
  Stream<SheetState> mapEventToState(
    SheetEvent event,
  ) async* {
    if (event is InitSheet) {
      yield SheetInitial(
        flow: flow,
      );
    } else if (event is CacheSheet) {
      // await repository.clean();
      // yield ProfileEmpty();
    }
  }
}
