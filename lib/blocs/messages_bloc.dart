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
  String _selectedChannelId;

  MessagesBloc({this.repository, this.channelsBloc}) : super(MessagesEmpty()) {
    subscription = channelsBloc.listen((ChannelState state) {
      if (state is ChannelsLoaded) {
        _selectedChannelId = state.selected.id;
        this.add(LoadMessages());
      }
    });
    _selectedChannelId = channelsBloc.repository.selected.id;
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      yield MessagesLoading();
    } else if (event is LoadSingleMessage) {
      Map<String, dynamic> queryParams = _makeQueryParams(event);
      await repository.pullOne(
        queryParams,
        addToItems: event.channelId == _selectedChannelId,
      );
      yield MessagesLoaded(messages: repository.items);
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }

  Map<String, dynamic> _makeQueryParams(MessagesEvent event) {
    Map<String, dynamic> map = event.toMap();
    map['channel_id'] = _selectedChannelId;
    map['company_id'] = channelsBloc.workspacesBloc.selectedCompanyId;
    map['workspace_id'] = channelsBloc.workspacesBloc.repository.selected.id;
    return map;
  }
}
