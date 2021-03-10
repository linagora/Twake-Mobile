import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/repositories/add_direct_repository.dart';
import 'package:twake/utils/extensions.dart';
import 'add_channel_event.dart';
import 'add_channel_state.dart';

class AddChannelBloc extends Bloc<AddChannelEvent, AddChannelState> {
  final AddChannelRepository channelRepository;
  final AddDirectRepository directRepository;

  AddChannelBloc(
    this.channelRepository,
    this.directRepository,
  ) : super(AddChannelInitial());

  @override
  Stream<AddChannelState> mapEventToState(
    AddChannelEvent event,
  ) async* {
    if (event is SetFlowStage) {
      yield StageUpdated(event.stage);
    } else if (event is Update) {
      channelRepository.icon = event.icon ?? channelRepository.icon;
      channelRepository.name =
          (event.name != null && event.name.isNotReallyEmpty)
              ? event.name
              : channelRepository.name;
      channelRepository.description =
          event.description ?? channelRepository.description;
      channelRepository.channelGroup =
          event.groupName ?? channelRepository.channelGroup;
      channelRepository.type =
          event.type ?? channelRepository.type ?? ChannelType.public;
      channelRepository.members =
          event.participants ?? channelRepository.members ?? [];
      channelRepository.def =
          event.automaticallyAddNew ?? channelRepository.def ?? true;

      // print('Updated data: ${repository.toJson()}');
      final newRepo = AddChannelRepository(
        icon: channelRepository.icon,
        companyId: channelRepository.companyId,
        workspaceId: channelRepository.workspaceId,
        name: channelRepository.name,
        visibility: channelRepository.visibility,
        description: channelRepository.description,
        channelGroup: channelRepository.channelGroup,
        type: channelRepository.type,
        members: channelRepository.members,
        def: channelRepository.def,
      );
      yield Updated(newRepo);
    } else if (event is UpdateDirect) {
      directRepository.member = event.member;
      // print('Updated data: ${repository.toJson()}');
      final newRepo = AddDirectRepository(
        companyId: directRepository.companyId,
        workspaceId: directRepository.workspaceId,
        member: directRepository.member,
      );
      yield DirectUpdated(newRepo);
    } else if (event is Create) {
      yield Creation();
      final type = channelRepository.type;
      final result = await channelRepository.create();
      if (result.isNotEmpty) {
        channelRepository.clear();
        yield Created(result, channelType: type);
      } else {
        yield Error('Channel creation failure!');
      }
    } else if (event is Clear) {
      channelRepository.clear();
    } else if (event is SetFlowType) {
      yield FlowTypeSet(event.isDirect);
    } else if (event is CreateDirect) {
      yield Creation();
      final result = await directRepository.create();
      if (result.isNotEmpty) {
        yield DirectCreated(result);
      } else {
        yield Error('Direct creation failure!');
      }
    }
  }
}
