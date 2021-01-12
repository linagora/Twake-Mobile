import 'dart:async';

import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
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
  final NotificationBloc notificationBloc;

  StreamSubscription _subscription;
  StreamSubscription _notificationSubscription;

  ChannelsBloc({
    CollectionRepository<Channel> repository,
    this.workspacesBloc,
    this.notificationBloc,
  }) : super(
            repository: repository,
            initState: repository.isEmpty
                ? ChannelsEmpty()
                : ChannelsLoaded(channels: repository.items)) {
    _subscription = workspacesBloc.listen((WorkspaceState state) {
      if (state is WorkspacesLoaded) {
        selectedParentId = state.selected.id;
        this.add(ReloadChannels(workspaceId: selectedParentId));
      }
    });
    _notificationSubscription =
        notificationBloc.listen((NotificationState state) {
      if (state is BaseChannelMessageNotification) {
        this.add(ModifyMessageCount(
          channelId: state.data.channelId,
          workspaceId: state.data.workspaceId,
          totalModifier: 1,
          unreadModifier: 1,
        ));
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
      if (repository.isEmpty) yield ChannelsEmpty();
      yield ChannelsLoaded(
        channels: repository.items,
      );
    } else if (event is ClearChannels) {
      await repository.clean();
      yield ChannelsEmpty();
    } else if (event is ChangeSelectedChannel) {
      repository.select(event.channelId, saveToStore: false);

      repository.selected.messagesUnread = 0;
      repository.saveOne(repository.selected);
      final newState = ChannelPicked(
        channels: repository.items,
        selected: repository.selected,
      );
      yield newState;
    } else if (event is ModifyMessageCount) {
      await this.updateMessageCount(event);
      if (event.workspaceId == selectedParentId) {
        yield ChannelsLoaded(
          channels: repository.items,
          force: DateTime.now().toString(),
        );
      }
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
    _notificationSubscription.cancel();
    return super.close();
  }
}
