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
        this.add(ModifyUnreadCount(
          channelId: state.data.channelId,
          companyId: state.data.companyId,
          modifier: 1,
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
        // TODO uncomment once we have correct company ids present
        // for now get all the data from database
        // filters: [
        // ['company_id', '=', selectedCompanyId]
        // ],
        sortFields: {'last_activity': false},
        forceFromApi: event.forceFromApi,
      );
      if (repository.isEmpty)
        yield ChannelsEmpty();
      else
        yield ChannelsLoaded(
          channels: repository.items,
        );
    } else if (event is ModifyUnreadCount) {
      final ch = await repository.getItemById(event.channelId);
      if (ch != null) {
        ch.messagesUnread += event.modifier;
        ch.messagesTotal += event.modifier.isNegative ? 0 : event.modifier;
        repository.saveOne(ch);
      } else
        return;
      // TODO uncomment condition when we have
      // company based direct chats
      // if (event.companyId == selectedParentId) {
      yield ChannelsLoaded(
        channels: repository.items,
        force: DateTime.now().toString(),
      );
      // }
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

  @override
  Future<void> close() {
    _subscription.cancel();
    _notificationSubscription.cancel();
    return super.close();
  }
}
