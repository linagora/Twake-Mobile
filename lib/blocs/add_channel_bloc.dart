import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/services/init.dart';
import 'package:twake/repositories/add_channel_repository.dart';

part '../events/add_channel_event.dart';

part '../states/add_channel_state.dart';

class AddChannelBloc extends Bloc<AddChannelEvent, AddChannelState> {
  final AddChannelRepository repository;

  AddChannelBloc(this.repository) : super(AddChannelInitial());

  @override
  Stream<AddChannelState> mapEventToState(
    AddChannelEvent event,
  ) async* {
    print('incoming event: $event');

    if (event is SetFlowStage) {
      print('incoming flow stage: ${event.stage}');
      yield StageUpdated(event.stage);

    } else if (event is Create) {
      yield Creation();
      final result = await repository.create();
      if (result) {
        yield Created();
      } else {
        yield Error('Channel creation failure!');
      }
    }
  }
}
