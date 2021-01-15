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
      repository.name = event.name ?? repository.name;
      repository.description = event.description ?? repository.description;
      repository.channelGroup = event.groupName ?? repository.channelGroup;
      repository.type = event.type ?? repository.type;
      repository.members = event.participants ?? repository.members;
      repository.def = event.automaticallyAddNew ?? repository.def;
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
