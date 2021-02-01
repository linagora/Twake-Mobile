import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/services/init.dart';
import 'package:twake/repositories/add_channel_repository.dart';

part 'add_channel_event.dart';

part 'add_channel_state.dart';

class AddChannelBloc extends Bloc<AddChannelEvent, AddChannelState> {
  final AddChannelRepository repository;

  AddChannelBloc(this.repository) : super(AddChannelInitial());

  @override
  Stream<AddChannelState> mapEventToState(
    AddChannelEvent event,
  ) async* {
    // print('incoming event: $event');
    if (event is Update) {
      repository.name = event.name ?? repository.name;
      repository.description = event.description ?? repository.description;
      repository.channelGroup = event.groupName ?? repository.channelGroup;
      repository.type = event.type ?? repository.type ?? ChannelType.public;
      repository.members = event.participants ?? repository.members ?? [];
      repository.def = event.automaticallyAddNew ?? repository.def ?? true;

      // print('Updated data: ${repository.toJson()}');
      var newRepo = AddChannelRepository(
        repository.companyId,
        repository.workspaceId,
        repository.name,
        repository.visibility,
        description: repository.description,
        channelGroup: repository.channelGroup,
        type: repository.type,
        members: repository.members,
        def: repository.def,
      );

      yield Updated(newRepo);

    } else if (event is Create) {
      yield Creation();
      final type = repository.type;
      final result = await repository.create();
      if (result.isNotEmpty) {
        yield Created(result, type);
      } else {
        yield Error('Channel creation failure!');
      }
    } else if (event is Clear) {
      repository.clear();
    } else if (event is SetFlowType) {
      yield FlowTypeSet(event.isDirect);
    }
  }
}
