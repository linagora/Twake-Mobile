import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/channel_state.dart';
import 'package:twake/states/workspace_state.dart';

class ChannelsBloc extends Bloc<ChannelsEvent, ChannelState> {
  final CollectionRepository repository;
  final WorkspacesBloc workspacesBloc;
  StreamSubscription subscription;
  String _selectedWorkspaceId;
  Channel selected;

  ChannelsBloc({this.repository, this.workspacesBloc})
      : super(ChannelsLoaded(
            channels: repository.items
                .where((i) =>
                    (i as Channel).workspaceId == workspacesBloc.selected.id)
                .toList(),
            selected: null)) {
    subscription = workspacesBloc.listen((WorkspaceState state) {
      if (state is WorkspacesLoaded) {
        _selectedWorkspaceId = state.selected.id;
        this.add(ReloadChannels(_selectedWorkspaceId));
      }
    });
  }

  List<Channel> get currentChannels {
    return repository.items
        .where((w) => (w as Channel).workspaceId == _selectedWorkspaceId)
        .toList();
  }

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    if (event is ReloadChannels) {
      await repository.reload();
      yield ChannelsLoaded(
        channels: currentChannels,
        selected: selected,
      );
    } else if (event is ClearChannels) {
      await repository.clean();
      yield ChannelsEmpty();
    } else if (event is ChangeSelectedChannel) {
      this.selected =
          repository.items.firstWhere((w) => w.id == event.channelId);

      yield ChannelsLoaded(
        channels: repository.items,
        selected: selected,
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
