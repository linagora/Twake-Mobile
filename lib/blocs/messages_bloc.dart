import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/events/messages_event.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/messages_state.dart';

export 'package:twake/states/messages_state.dart';
export 'package:twake/events/messages_event.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final CollectionRepository repository;
  final ChannelsBloc channelsBloc;
  StreamSubscription subscription;
  String selectedChannelId;

  MessagesBloc({this.repository, this.channelsBloc}) : super(MessagesEmpty()) {
    subscription = channelsBloc.listen((ChannelState state) {
      if (state is ChannelsLoaded) {
        selectedChannelId = state.selected.id;
        this.add(LoadMessages());
      }
    });
    selectedChannelId = channelsBloc.repository.selected.id;
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      yield MessagesLoading();
      List<List> filters = [
        ['channel_id', '=', selectedChannelId]
      ];
      await repository.reload(
        queryParams: _makeQueryParams(event),
        filters: filters,
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty();
      else
        yield MessagesLoaded(messages: repository.items);
    } else if (event is LoadSingleMessage) {
      await repository.pullOne(
        _makeQueryParams(event),
        addToItems: event.channelId == selectedChannelId,
      );
      yield MessagesLoaded(messages: repository.items);
    } else if (event is RemoveMessage) {
      await repository.delete(
        event.messageId,
        apiSync: !event.onNotify,
        removeFromItems: event.channelId == selectedChannelId,
        requestBody: _makeQueryParams(event),
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty();
      else
        yield MessagesLoaded(messages: repository.items);
    } else if (event is SendMessage) {
      await repository.add(_makeQueryParams(event));
      yield MessagesLoaded(messages: repository.items);
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty();
    } else if (event is SelectMessage) {
      repository.select(event.messageId);
      yield MessageSelected(repository.selected);
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }

  Map<String, dynamic> _makeQueryParams(MessagesEvent event) {
    Map<String, dynamic> map = event.toMap();
    map['channel_id'] = map['channel_id'] ?? selectedChannelId;
    map['company_id'] = channelsBloc.workspacesBloc.selectedCompanyId;
    map['workspace_id'] = channelsBloc.workspacesBloc.repository.selected.id;
    return map;
  }
}
