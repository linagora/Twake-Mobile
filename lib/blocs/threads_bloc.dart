import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc.dart';
import 'package:twake/blocs/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/events/messages_event.dart';
import 'package:twake/models/message.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/messages_state.dart';

export 'package:twake/states/messages_state.dart';
export 'package:twake/events/messages_event.dart';

const _THREAD_MESSAGES_LIMIT = 1000;

class ThreadsBloc<T extends BaseChannelBloc>
    extends Bloc<MessagesEvent, MessagesState> {
  final CollectionRepository<Message> repository;
  final MessagesBloc<T> messagesBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription notificationSubscription;
  StreamSubscription messagesSubscription;

  ThreadsBloc({
    this.repository,
    this.messagesBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty()) {
    messagesSubscription = messagesBloc.listen((MessagesState state) {
      if (state is MessageSelected) {
        this.add(LoadMessages(
          threadId: state.threadMessage.id,
          channelId: state.parentChannel.id,
        ));
      }
    });
    notificationSubscription =
        notificationBloc.listen((NotificationState state) {
      if (state is ThreadMessageNotification) {
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          threadId: state.data.threadId,
          channelId: state.data.channelId,
        ));
      }
    });
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      yield MessagesLoading();
      List<List> filters = [
        ['thread_id', '=', event.threadId],
      ];
      await repository.reload(
        queryParams: _makeQueryParams(event),
        filters: filters,
        sortFields: {'creation_date': true},
        limit: _THREAD_MESSAGES_LIMIT,
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty();
      else {
        _sortItems();
        yield MessagesLoaded(
          messageCount: repository.itemsCount,
          messages: repository.items,
        );
      }
    } else if (event is LoadSingleMessage) {
      await repository.pullOne(
        _makeQueryParams(event),
        addToItems: event.threadId == event.threadId,
      );
      _sortItems();
      yield MessagesLoaded(
        messageCount: repository.itemsCount,
        messages: repository.items,
      );
    } else if (event is RemoveMessage) {
      await repository.delete(
        event.messageId,
        apiSync: !event.onNotify,
        removeFromItems: event.threadId == event.threadId,
        requestBody: _makeQueryParams(event),
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty();
      else {
        _sortItems();
        yield MessagesLoaded(
          messageCount: repository.itemsCount,
          messages: repository.items,
        );
      }
    } else if (event is SendMessage) {
      final success = await repository.pushOne(_makeQueryParams(event));
      if (success) {
        yield MessagesLoaded(
          messageCount: repository.itemsCount,
          messages: repository.items,
        );
        _updateParentChannel();
      }
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty();
    }
  }

  @override
  Future<void> close() {
    notificationSubscription.cancel();
    messagesSubscription.cancel();
    return super.close();
  }

  Map<String, dynamic> _makeQueryParams(MessagesEvent event) {
    Map<String, dynamic> map = event.toMap();
    map['company_id'] = map['company_id'] ?? ProfileBloc.selectedCompany;
    map['workspace_id'] = map['workspace_id'] ?? ProfileBloc.selectedWorkspace;
    map['limit'] = _THREAD_MESSAGES_LIMIT.toString();
    return map;
  }

  void _sortItems() {
    repository.items.sort(
      (i1, i2) => i2.creationDate.compareTo(i1.creationDate),
    );
  }

  void _updateParentChannel() {
    final channelId = messagesBloc.selectedChannel.id;
    messagesBloc.channelsBloc.add(ModifyMessageCount(
      channelId: channelId,
      companyId: ProfileBloc.selectedCompany,
      totalModifier: 1,
    ));
  }
}
