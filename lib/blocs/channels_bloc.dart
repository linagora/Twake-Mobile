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
  final CollectionRepository repository;
  final WorkspacesBloc workspacesBloc;
  StreamSubscription subscription;
  String _selectedWorkspaceId;

  ChannelsBloc({this.repository, this.workspacesBloc})
      : super(ChannelsLoaded(
            channels: repository.items
                .where((i) =>
                    (i as Channel).workspaceId ==
                    workspacesBloc.repository.selected.id)
                .toList(),
            selected: repository.selected)) {
    subscription = workspacesBloc.listen((WorkspaceState state) {
      if (state is WorkspacesLoaded) {
        _selectedWorkspaceId = state.selected.id;
        this.add(ReloadChannels(workspaceId: _selectedWorkspaceId));
      }
    });
    _selectedWorkspaceId = workspacesBloc.repository.selected.id;
  }

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    if (event is ReloadChannels) {
      yield ChannelsLoading();
      await repository.reload(
        queryParams: {
          'workspace_id': event.workspaceId ?? _selectedWorkspaceId
        },
        filters: [
          ['workspace_id', '=', event.workspaceId ?? _selectedWorkspaceId]
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
      Channel ch = repository.items.firstWhere((w) => w.id == event.channelId);
      repository.selected.isSelected = false;
      ch.isSelected = true;

      yield ChannelsLoaded(
        channels: repository.items,
        selected: ch,
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
