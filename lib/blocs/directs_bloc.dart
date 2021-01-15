import 'dart:async';

import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/channel_state.dart';

export 'package:twake/events/channel_event.dart';
export 'package:twake/states/channel_state.dart';

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
        notificationBloc.listen((NotificationState state) {
      if (state is BaseChannelMessageNotification) {
        this.add(ModifyMessageCount(
          channelId: state.data.channelId,
          companyId: state.data.companyId,
          totalModifier: 1,
          unreadModifier: 1,
        ));
      }
    });
    selectedParentId = companiesBloc.repository.selected.id;
  }

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    if (event is ReloadChannels) {
      yield ChannelsLoading();
      final filter = {
        'company_id': event.companyId,
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
      else
        yield ChannelsLoaded(
          channels: repository.items,
        );
    } else if (event is ModifyMessageCount) {
      await this.updateMessageCount(event);
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
      repository.select(event.channelId);

      repository.selected.messagesUnread = 0;
      repository.saveOne(repository.selected);
      yield ChannelPicked(
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
