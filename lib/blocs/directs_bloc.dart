import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/channel_state.dart';

export 'package:twake/events/channel_event.dart';
export 'package:twake/states/channel_state.dart';

class DirectsBloc extends Bloc<ChannelsEvent, ChannelState> {
  final CollectionRepository<Direct> repository;
  final CompaniesBloc companiesBloc;
  StreamSubscription subscription;
  String selectedCompanyId;

  DirectsBloc({
    this.repository,
    this.companiesBloc,
  }) : super(repository.items.isEmpty
            ? ChannelsEmpty()
            : DirectsLoaded(
                directs: repository.items,
                selected: repository.selected,
              )) {
    subscription = companiesBloc.listen((CompaniesState state) {
      if (state is CompaniesLoaded) {
        selectedCompanyId = state.selected.id;
        this.add(ReloadChannels(companyId: selectedCompanyId));
      }
    });
    selectedCompanyId = companiesBloc.repository.selected.id;
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
        sortFields: {'name': true},
        forceFromApi: event.forceFromApi,
      );
      if (repository.items.isEmpty)
        yield ChannelsEmpty();
      else
        yield DirectsLoaded(
          directs: repository.items,
          selected: repository.selected,
        );
    } else if (event is ClearChannels) {
      await repository.clean();
      yield ChannelsEmpty();
    } else if (event is ChangeSelectedChannel) {
      repository.select(event.channelId);

      yield DirectsLoaded(
        directs: repository.items,
        selected: repository.selected,
        fetchMessages: true,
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
