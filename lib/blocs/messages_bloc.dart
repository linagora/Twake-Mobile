import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
import 'package:twake/events/messages_event.dart';
import 'package:twake/models/base_channel.dart';
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

  BaseChannel selectedChannel;

  MessagesBloc({
    this.repository,
    this.channelsBloc,
    this.directsBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty(parentChannel: channelsBloc.repository.selected)) {
    channelsSubscription = channelsBloc.listen((ChannelState state) {
      repository.logger.d('TRIGGERED MESSAGE FETCH: $state');
      if (state is ChannelsLoaded && state.fetchMessages) {
        repository.logger
            .d('FETCHING CHANNEL MESSAGES: ${state.selected.name}');
        selectedChannel = state.selected;
        this.add(LoadMessages());
      }
    });
    directsSubscription = directsBloc.listen((ChannelState state) {
      if (state is DirectsLoaded && state.fetchMessages) {
        selectedChannel = state.selected;
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
    selectedChannel = channelsBloc.repository.selected;
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      yield MessagesLoading(parentChannel: selectedChannel);
      await repository.reload(
        queryParams: _makeQueryParams(event),
        filters: [
          ['channel_id', '=', selectedChannel.id]
        ],
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty(parentChannel: selectedChannel);
      else {
        await UserRepository().batchUsersLoad(
          repository.items.map((i) => i.userId).toSet(),
        );
        yield MessagesLoaded(
          messages: repository.items,
          parentChannel: selectedChannel,
        );
      }
    } else if (event is LoadSingleMessage) {
      await repository.pullOne(
        _makeQueryParams(event),
        addToItems: event.channelId == selectedChannel.id,
      );
      yield MessagesLoaded(
        messages: repository.items,
        parentChannel: selectedChannel,
      );
    } else if (event is RemoveMessage) {
      await repository.delete(
        event.messageId,
        apiSync: !event.onNotify,
        removeFromItems: event.channelId == selectedChannel.id,
        requestBody: _makeQueryParams(event),
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty(parentChannel: selectedChannel);
      else
        yield MessagesLoaded(
          messages: repository.items,
          parentChannel: selectedChannel,
        );
    } else if (event is SendMessage) {
      await repository.pushOne(_makeQueryParams(event));
      yield MessagesLoaded(
        messages: repository.items,
        parentChannel: selectedChannel,
      );
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty(parentChannel: selectedChannel);
    } else if (event is SelectMessage) {
      repository.select(event.messageId);
      yield MessageSelected(
        threadMessage: repository.selected,
        parentChannel: selectedChannel,
      );
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
    map['channel_id'] = map['channel_id'] ?? selectedChannel.id;
    map['company_id'] = directsBloc.selectedCompanyId;
    map['workspace_id'] = channelsBloc.selectedWorkspaceId;
    return map;
  }
}
