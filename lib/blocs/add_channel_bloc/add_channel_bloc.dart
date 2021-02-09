import 'dart:async';
import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/channel_repository.dart';
import 'add_channel_event.dart';
import 'add_channel_state.dart';

class AddChannelBloc extends Bloc<AddChannelEvent, AddChannelState> {
  final ChannelRepository repository;

  AddChannelBloc(this.repository) : super(AddChannelInitial());

  @override
  Stream<AddChannelState> mapEventToState(
    AddChannelEvent event,
  ) async* {
    if (event is SetFlowStage) {
      yield StageUpdated(event.stage);
    } else if (event is Update) {
      repository.name = event.name ?? repository.name;
      repository.description = event.description ?? repository.description;
      repository.channelGroup = event.groupName ?? repository.channelGroup;
      repository.type = event.type ?? repository.type ?? ChannelType.public;
      repository.members = event.participants ?? repository.members ?? [];
      repository.def = event.automaticallyAddNew ?? repository.def ?? true;

      // print('Updated data: ${repository.toJson()}');
      var newRepo = ChannelRepository(
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
        repository.clear();
        yield Created(result, type);
      } else {
        yield Error('Channel creation failure!');
      }
    } else if (event is Clear) {
      repository.clear();
    } else if (event is SetFlowType) {
      yield FlowTypeSet(event.isDirect);
    } else if (event is UpdateMembers) {
      final channelId = event.channelId;
      final members = event.members;
      final result = await repository.updateMembers(
        members: members,
        channelId: channelId,
      );
      if (result) {
        yield MembersUpdated(channelId: channelId, members: members);
      } else {
        yield Error('Members update failure!');
      }
    }
  }
}
