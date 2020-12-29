import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
import 'package:twake/events/messages_event.dart';
import 'package:twake/models/message.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/repositories/user_repository.dart';
import 'package:twake/states/messages_state.dart';

export 'package:twake/states/messages_state.dart';
export 'package:twake/events/messages_event.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final CollectionRepository<Message> repository;
  final ChannelsBloc channelsBloc;
  final DirectsBloc directsBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription channelsSubscription;
  StreamSubscription directsSubscription;
  StreamSubscription notificationSubscription;

  String selectedChannelId;

  MessagesBloc({
    this.repository,
    this.channelsBloc,
    this.directsBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty()) {
    channelsSubscription = channelsBloc.listen((ChannelState state) {
      if (state is ChannelsLoaded) {
        selectedChannelId = state.selected.id;
        this.add(LoadMessages());
      }
    });
    directsSubscription = directsBloc.listen((ChannelState state) {
      if (state is DirectsLoaded) {
        selectedChannelId = state.selected.id;
        this.add(LoadMessages());
      }
    });
    notificationSubscription =
        notificationBloc.listen((NotificationState state) {
      if (state is ChannelMessageNotification) {
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          channelId: state.data.channelId,
        ));
      }
    });
    selectedChannelId = channelsBloc.repository.selected.id;
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      yield MessagesLoading();
      await repository.reload(
        queryParams: _makeQueryParams(event),
        filters: [
          ['channel_id', '=', selectedChannelId]
        ],
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty();
      else {
        await UserRepository().batchUsersLoad(
          repository.items.map((i) => i.sender['user_id']).toSet(),
        );
        yield MessagesLoaded(messages: repository.items);
      }
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
      await repository.pushOne(_makeQueryParams(event));
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
    channelsSubscription.cancel();
    directsSubscription.cancel();
    notificationSubscription.cancel();
    return super.close();
  }

  Map<String, dynamic> _makeQueryParams(MessagesEvent event) {
    Map<String, dynamic> map = event.toMap();
    map['channel_id'] = map['channel_id'] ?? selectedChannelId;
    map['company_id'] = directsBloc.selectedCompanyId;
    map['workspace_id'] = channelsBloc.selectedWorkspaceId;
    return map;
  }
}
