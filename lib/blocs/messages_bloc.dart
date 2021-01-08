import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/events/messages_event.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/message.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/repositories/user_repository.dart';
import 'package:twake/states/messages_state.dart';

export 'package:twake/states/messages_state.dart';
export 'package:twake/events/messages_event.dart';

const _MESSAGE_LIMIT = 50;

class MessagesBloc<T extends BaseChannelBloc>
    extends Bloc<MessagesEvent, MessagesState> {
  final CollectionRepository<Message> repository;
  final T channelsBloc;
  final ThreadsBloc threadsBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription _subscription;
  StreamSubscription _notificationSubscription;

  BaseChannel selectedChannel;

  String _previousMessageId;

  MessagesBloc({
    this.repository,
    this.channelsBloc,
    this.threadsBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty(parentChannel: channelsBloc.repository.selected)) {
    _subscription = channelsBloc.listen((ChannelState state) {
      if (state is ChannelPicked) {
        repository.logger.d('TRIGGERED MESSAGE FETCH');
        repository.logger
            .d('FETCHING CHANNEL MESSAGES: ${state.selected.name}');
        selectedChannel = state.selected;
        this.add(LoadMessages());
      }
    });
    _notificationSubscription =
        notificationBloc.listen((NotificationState state) {
      if (T == ChannelsBloc && state is ChannelMessageNotification) {
        repository.logger.d('CHANNEL MESSAGE FETCH ON NOTIFY');
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          channelId: state.data.channelId,
          workspaceId: state.data.workspaceId,
          companyId: state.data.companyId,
        ));
      }
      if (T == DirectsBloc && state is DirectMessageNotification) {
        repository.logger.d('DIRECT MESSAGE FETCH ON NOTIFY');
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          channelId: state.data.channelId,
          workspaceId: state.data.workspaceId,
          companyId: state.data.companyId,
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
          ['channel_id', '=', selectedChannel.id],
          ['thread_id', '=', null],
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
          messageCount: repository.itemsCount,
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
          ['thread_id', '=', null],
        ],
        sortFields: {'creation_date': false},
      );
      _sortItems();
      yield MessagesLoaded(
        messages: repository.items,
        messageCount: repository.itemsCount,
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
        messageCount: repository.itemsCount,
        parentChannel: selectedChannel,
      );
      repository.logger.d('YIELDING STATE: ${newState != this.state}');
      yield newState;
    } else if (event is RemoveMessage) {
      final channelId = event.channelId ?? selectedChannel.id;
      repository.logger
          .d('DELETING IN CURRENT CHANNEL: ${channelId == selectedChannel.id}');
      await repository.delete(
        event.messageId,
        apiSync: !event.onNotify,
        removeFromItems: channelId == selectedChannel.id,
        requestBody: _makeQueryParams(event),
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty(parentChannel: selectedChannel);
      else {
        _sortItems();

        final newState = MessagesLoaded(
          messages: repository.items,
          messageCount: repository.itemsCount,
          parentChannel: selectedChannel,
        );

        repository.logger
            .d('Removed message, new state will yield: ${newState == state}');
        yield newState;
      }
    } else if (event is SendMessage) {
      await repository.pushOne(_makeQueryParams(event));
      _sortItems();
      yield MessagesLoaded(
        messages: repository.items,
        messageCount: repository.itemsCount,
        parentChannel: selectedChannel,
      );
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty(parentChannel: selectedChannel);
    } else if (event is SelectMessage) {
      repository.select(event.messageId);
      threadsBloc.add(LoadMessages(
        threadId: event.messageId,
        channelId: selectedChannel.id,
      ));
      yield MessageSelected(
        threadMessage: repository.selected,
        messages: repository.items,
        parentChannel: selectedChannel,
      );
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _notificationSubscription.cancel();
    return super.close();
  }

  Map<String, dynamic> _makeQueryParams(MessagesEvent event) {
    Map<String, dynamic> map = event.toMap();
    map['channel_id'] = map['channel_id'] ?? selectedChannel.id;
    map['company_id'] = map['company_id'] ?? ProfileBloc().selectedCompany;
    map['workspace_id'] =
        map['workspace_id'] ?? ProfileBloc().selectedWorkspace;
    return map;
  }

  void _sortItems() {
    repository.items.sort(
      (i1, i2) => i1.creationDate.compareTo(i2.creationDate),
    );
  }
}
