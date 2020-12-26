import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/channel_state.dart';
import 'package:twake/states/workspace_state.dart';

export 'package:twake/events/channel_event.dart';
export 'package:twake/states/channel_state.dart';

class ChannelsBloc extends Bloc<ChannelsEvent, ChannelState> {
  final CollectionRepository<Channel> repository;
  final WorkspacesBloc workspacesBloc;
  StreamSubscription subscription;
  String selectedWorkspaceId;

  ChannelsBloc({this.repository, this.workspacesBloc})
      : super(ChannelsLoaded(
            channels: repository.items
                .where((i) =>
                    i.workspaceId == workspacesBloc.repository.selected.id)
                .toList(),
            selected: repository.selected)) {
    subscription = workspacesBloc.listen((WorkspaceState state) {
      if (state is WorkspacesLoaded) {
        selectedWorkspaceId = state.selected.id;
        this.add(ReloadChannels(workspaceId: selectedWorkspaceId));
      }
    });
    selectedWorkspaceId = workspacesBloc.repository.selected.id;
  }

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    if (event is ReloadChannels) {
      yield ChannelsLoading();
      await repository.reload(
        queryParams: {
          'workspace_id': event.workspaceId ?? selectedWorkspaceId,
          'company_id': workspacesBloc.selectedCompanyId,
        },
        filters: [
          ['workspace_id', '=', event.workspaceId ?? selectedWorkspaceId]
        ],
        sortFields: {'name': true},
        forceFromApi: event.forceFromApi,
      );
      yield ChannelsLoaded(
        channels: repository.items,
        selected: repository.selected,
      );
    } else if (event is ClearChannels) {
      await repository.clean();
      yield ChannelsEmpty();
    } else if (event is ChangeSelectedChannel) {
      repository.select(event.channelId);

      yield ChannelsLoaded(
        channels: repository.items,
        selected: repository.selected,
      );
    } else if (event is LoadSingleChannel) {
      // TODO implement single company loading
      throw 'Not implemented yet';
    } else if (event is RemoveChannel) {
      throw 'Not implemented yet';
      // repository.items.removeWhere((i) => i.id == event.channelId);
      // yield ChannelsLoaded(
      // channels: repository.items,
      // selected: selected,
      // );
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
