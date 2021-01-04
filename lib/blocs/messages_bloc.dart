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

const _MESSAGE_LIMIT = 50;

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final CollectionRepository<Message> repository;
  final ChannelsBloc channelsBloc;
  final DirectsBloc directsBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription _channelsSubscription;
  StreamSubscription _directsSubscription;
  StreamSubscription _notificationSubscription;

  BaseChannel selectedChannel;

  String _previousMessageId;

  MessagesBloc({
    this.repository,
    this.channelsBloc,
    this.directsBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty(parentChannel: channelsBloc.repository.selected)) {
    _channelsSubscription = channelsBloc.listen((ChannelState state) {
      repository.logger.d('TRIGGERED MESSAGE FETCH: $state');
      if (state is ChannelPicked) {
        repository.logger
            .d('FETCHING CHANNEL MESSAGES: ${state.selected.name}');
        selectedChannel = state.selected;
        this.add(LoadMessages());
      }
    });
    _directsSubscription = directsBloc.listen((ChannelState state) {
      if (state is DirectPicked) {
        selectedChannel = state.selected;
        this.add(LoadMessages());
      }
    });
    _notificationSubscription =
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
        sortFields: {'creation_date': false},
        limit: _MESSAGE_LIMIT,
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty(parentChannel: selectedChannel);
      else {
        await UserRepository().batchUsersLoad(
          repository.items.map((i) => i.userId).toSet(),
        );
        _sortItems();
        yield MessagesLoaded(
          messages: repository.items,
          messageCount: repository.items.length,
          parentChannel: selectedChannel,
        );
      }
    } else if (event is LoadMoreMessages) {
      if (_previousMessageId == event.beforeId) return;
      _previousMessageId = event.beforeId;
      yield MoreMessagesLoading(
        messages: repository.items,
        parentChannel: selectedChannel,
      );
      final bool _ = await repository.loadMore(
        queryParams: _makeQueryParams(event),
        filters: [
          ['channel_id', '=', selectedChannel.id],
          ['creation_date', '<', event.beforeTimeStamp],
        ],
        sortFields: {'creation_date': false},
      );
      _sortItems();
      yield MessagesLoaded(
        messages: repository.items,
        messageCount: repository.items.length,
        parentChannel: selectedChannel,
      );
    } else if (event is LoadSingleMessage) {
      repository.logger
          .d('IS IN CURRENT CHANNEL: ${event.channelId == selectedChannel.id}');
      await repository.pullOne(
        _makeQueryParams(event),
        // addToItems: event.channelId == selectedChannel.id,
        addToItems: event.channelId == selectedChannel.id,
      );
      _sortItems();
      final newState = MessagesLoaded(
        messages: repository.items,
        messageCount: repository.items.length,
        parentChannel: selectedChannel,
      );
      repository.logger.d('YIELDING STATE: ${newState == this.state}');
      yield newState;
    } else if (event is RemoveMessage) {
      await repository.delete(
        event.messageId,
        apiSync: !event.onNotify,
        removeFromItems: event.channelId == selectedChannel.id,
        requestBody: _makeQueryParams(event),
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty(parentChannel: selectedChannel);
      else {
        _sortItems();
        yield MessagesLoaded(
          messages: repository.items,
          messageCount: repository.items.length,
          parentChannel: selectedChannel,
        );
      }
    } else if (event is SendMessage) {
      await repository.pushOne(_makeQueryParams(event));
      _sortItems();
      yield MessagesLoaded(
        messages: repository.items,
        messageCount: repository.items.length,
        parentChannel: selectedChannel,
      );
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty(parentChannel: selectedChannel);
    } else if (event is SelectMessage) {
      repository.select(event.messageId);
      yield MessageSelected(
        threadMessage: repository.selected,
        messages: repository.items,
        parentChannel: selectedChannel,
      );
    }
  }

  @override
  Future<void> close() {
    _channelsSubscription.cancel();
    _directsSubscription.cancel();
    _notificationSubscription.cancel();
    return super.close();
  }

  Map<String, dynamic> _makeQueryParams(MessagesEvent event) {
    Map<String, dynamic> map = event.toMap();
    map['channel_id'] = map['channel_id'] ?? selectedChannel.id;
    map['company_id'] = directsBloc.selectedCompanyId;
    map['workspace_id'] = channelsBloc.selectedWorkspaceId;
    return map;
  }

  void _sortItems() {
    repository.items.sort(
      (i1, i2) => i2.creationDate.compareTo(i1.creationDate),
    );
  }
}
