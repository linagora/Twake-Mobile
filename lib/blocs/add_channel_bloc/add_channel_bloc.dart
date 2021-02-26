import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'add_channel_event.dart';
import 'add_channel_state.dart';

class AddChannelBloc extends Bloc<AddChannelEvent, AddChannelState> {
  final AddChannelRepository repository;

  AddChannelBloc(this.repository) : super(AddChannelInitial());

  @override
  Stream<AddChannelState> mapEventToState(
    AddChannelEvent event,
  ) async* {
    if (event is SetFlowStage) {
      yield StageUpdated(event.stage);
    } else if (event is Update) {
      repository.icon = event.icon ?? repository.icon;
      repository.name = event.name ?? repository.name;
      repository.description = event.description ?? repository.description;
      repository.channelGroup = event.groupName ?? repository.channelGroup;
      repository.type = event.type ?? repository.type ?? ChannelType.public;
      repository.members = event.participants ?? repository.members ?? [];
      repository.def = event.automaticallyAddNew ?? repository.def ?? true;

      // print('Updated data: ${repository.toJson()}');
      var newRepo = AddChannelRepository(
        icon: repository.icon,
        companyId: repository.companyId,
        workspaceId: repository.workspaceId,
        name: repository.name,
        visibility: repository.visibility,
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
    }
  }
}
