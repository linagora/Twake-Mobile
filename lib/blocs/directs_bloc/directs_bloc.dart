import 'dart:async';

import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/companies_bloc/companies_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/blocs/channels_bloc/channel_event.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/blocs/channels_bloc/channel_state.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/blocs/channels_bloc/channel_event.dart';
export 'package:twake/blocs/channels_bloc/channel_state.dart';

class DirectsBloc extends BaseChannelBloc {
  final CompaniesBloc companiesBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription _subscription;
  StreamSubscription _notificationSubscription;

  DirectsBloc({
    CollectionRepository<Direct> repository,
    this.companiesBloc,
    this.notificationBloc,
  }) : super(
            repository: repository,
            initState: repository.isEmpty
                ? ChannelsEmpty()
                : ChannelsLoaded(channels: repository.items)) {
    _subscription = companiesBloc.listen((CompaniesState state) {
      if (state is CompaniesLoaded) {
        selectedParentId = state.selected.id;
        this.add(ReloadChannels(companyId: selectedParentId));
      }
    });
    _notificationSubscription =
        notificationBloc.listen((NotificationState state) async {
      if (state is DirectMessageNotification) {
        this.add(ChangeSelectedChannel(state.data.channelId));
      } else if (state is BaseChannelMessageNotification &&
          state.data.workspaceId == 'direct') {
        while (true) {
          if (selectedParentId == state.data.companyId &&
              this.state is ChannelsLoaded) {
            this.add(ChangeSelectedChannel(state.data.channelId));
            break;
          } else {
            await Future.delayed(Duration(milliseconds: 500));
          }
        }
      } else if (state is DirectUpdated) {
        if (repository.items.any((d) => d.id == state.data.directId)) {
          this.add(UpdateSingleChannel(state.data));
        } else {
          this.add(ReloadChannels(forceFromApi: true, silent: true));
        }
      } else if (state is DirectDeleted) {
        this.add(RemoveChannel(channelId: state.data.directId));
      }
    });
    selectedParentId = companiesBloc.repository.selected.id;
  }

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    print('Event in DirectsBloc: $event');

    if (event is ReloadChannels) {
      if (!event.silent) yield ChannelsLoading();
      final filter = {
        'company_id': event.companyId ?? selectedParentId,
      };
      await repository.reload(
        queryParams: filter,
        filters: [
          ['company_id', '=', selectedParentId]
        ],
        sortFields: {'last_activity': false},
        forceFromApi: event.forceFromApi,
      );
      if (repository.isEmpty)
        yield ChannelsEmpty();
      else {
        _sortItems();
        yield ChannelsLoaded(
          channels: repository.items,
        );
      }
    } else if (event is ModifyMessageCount) {
      await this.updateMessageCount(event);
      repository.logger
          .d('REORDERING DIRECTS ${event.companyId == selectedParentId}');
      if (event.companyId == selectedParentId) {
        _sortItems();
        yield ChannelsLoaded(
          channels: repository.items,
          force: DateTime.now().toString(),
        );
      }
    } else if (event is ClearChannels) {
      await repository.clean();
      yield ChannelsEmpty();
    } else if (event is ChangeSelectedChannel) {
      repository.select(event.channelId,
          saveToStore: false,
          apiEndpoint: Endpoint.channelsRead,
          params: {
            "company_id": ProfileBloc.selectedCompanyId,
            "workspace_id": "direct",
            "channel_id": event.channelId
          });
      repository.selected.messagesUnread = 0;
      repository.selected.hasUnread = 0;
      repository.saveOne(repository.selected);

      ProfileBloc.selectedChannelId = event.channelId;
      ProfileBloc.selectedThreadId = null;

      yield ChannelPicked(
        channels: repository.items,
        selected: repository.selected,
      );
      notificationBloc.add(CancelPendingSubscriptions(event.channelId));
    } else if (event is UpdateSingleChannel) {
      // repository.logger.d('UPDATING CHANNELS\n${event.data.toJson()}');
      var item = await repository.getItemById(event.data.directId) as Direct;
      item.lastMessage = event.data.lastMessage ?? item.lastMessage;
      item.lastActivity = event.data.lastActivity ?? item.lastActivity;
      yield ChannelsLoaded(
        selected: repository.selected,
        channels: repository.items,
        force: DateTime.now().toString(),
      );
    } else if (event is LoadSingleChannel) {
      throw 'Not implemented yet';
    } else if (event is RemoveChannel) {
      repository.items.removeWhere((i) => i.id == event.channelId);
      yield ChannelsLoaded(
        channels: repository.items,
        selected: repository.selected,
        force: DateTime.now().toString(),
      );
    } else if (event is ModifyChannelState) {
      await updateChannelState(event);
      yield ChannelsLoaded(
        channels: repository.items,
        force: DateTime.now().toString(),
      );
    }
  }

  void _sortItems() {
    repository.items.sort(
      (i1, i2) => i2.lastActivity.compareTo(i1.lastActivity),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _notificationSubscription.cancel();
    return super.close();
  }
}
