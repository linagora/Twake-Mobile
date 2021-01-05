import 'dart:async';

import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/channel_state.dart';
import 'package:twake/states/workspace_state.dart';

export 'package:twake/events/channel_event.dart';
export 'package:twake/states/channel_state.dart';

class ChannelsBloc extends BaseChannelBloc {
  final WorkspacesBloc workspacesBloc;
  StreamSubscription _subscription;

  ChannelsBloc({CollectionRepository<Channel> repository, this.workspacesBloc})
      : super(
            repository: repository,
            initState: ChannelsLoaded(channels: repository.items)) {
    _subscription = workspacesBloc.listen((WorkspaceState state) {
      if (state is WorkspacesLoaded) {
        selectedParentId = state.selected.id;
        this.add(ReloadChannels(workspaceId: selectedParentId));
      }
    });
    selectedParentId = workspacesBloc.repository.selected.id;
  }

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    if (event is ReloadChannels) {
      yield ChannelsLoading();
      await repository.reload(
        queryParams: {
          'workspace_id': event.workspaceId ?? selectedParentId,
          'company_id': workspacesBloc.selectedCompanyId,
        },
        filters: [
          ['workspace_id', '=', event.workspaceId ?? selectedParentId]
        ],
        sortFields: {'name': true},
        forceFromApi: event.forceFromApi,
      );
      yield ChannelsLoaded(
        channels: repository.items,
      );
    } else if (event is ClearChannels) {
      await repository.clean();
      yield ChannelsEmpty();
    } else if (event is ChangeSelectedChannel) {
      repository.select(event.channelId, saveToStore: false);
      final newState = ChannelPicked(
        channels: repository.items,
        selected: repository.selected,
      );
      yield newState;
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
    _subscription.cancel();
    return super.close();
  }
}
