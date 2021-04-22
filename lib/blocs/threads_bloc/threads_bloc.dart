import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_event.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/message.dart';
import 'package:twake/blocs/messages_bloc/messages_state.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/utils/twacode.dart';

export 'package:twake/blocs/messages_bloc/messages_state.dart';
export 'package:twake/blocs/messages_bloc/messages_event.dart';

const _THREAD_MESSAGES_LIMIT = 1000;
const _DUMMY_ID = 'message';

class ThreadsBloc<T extends BaseChannelBloc>
    extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository repository;
  final MessagesBloc<T> messagesBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription notificationSubscription;
  StreamSubscription messagesSubscription;

  Message threadMessage;
  BaseChannel parentChannel;

  ThreadsBloc({
    this.repository,
    this.messagesBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty()) {
    messagesSubscription = messagesBloc.listen((MessagesState state) {
      if (state is MessageSelected) {
        this.threadMessage = state.threadMessage;
        this.parentChannel = state.parentChannel;
        this.add(LoadMessages(
          threadId: state.threadMessage.id,
          channelId: state.parentChannel.id,
        ));
      } else if (state is MessagesLoaded &&
          state.threadMessage != null &&
          this.threadMessage != null) {
        // repository.logger.w(
        // "${state.threadMessage.content.originalStr} == ${threadMessage.content.originalStr}");
        if (threadMessage.id == state.threadMessage.id &&
            (threadMessage.content.originalStr !=
                    state.threadMessage.content.originalStr ||
                threadMessage.reactions.keys !=
                    state.threadMessage.reactions.keys))
          this.add(UpdateThreadMessage(state.threadMessage));
      }
    });
    notificationSubscription =
        notificationBloc.listen((NotificationState state) {
      if (state is DirectThreadMessageArrived && T == DirectsBloc) {
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          threadId: state.data.threadId,
          channelId: state.data.channelId,
        ));
      } else if (state is ChannelThreadMessageArrived && T == ChannelsBloc) {
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          threadId: state.data.threadId,
          channelId: state.data.channelId,
        ));
      } else if (state is ThreadMessageDeleted &&
          messagesBloc.channelsBloc != null) {
        this.add(RemoveMessage(
          channelId: state.data.channelId,
          threadId: state.data.threadId,
          messageId: state.data.messageId,
          onNotify: true,
        ));
      } else if (state is ThreadMessageNotification) {
        this.add(InfinitelyLoadMessages());
      }
    });
    parentChannel = messagesBloc.selectedChannel;
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      // print("SELECTED THREAD: ${threadMessage.toJson()}");
      if (threadMessage.responsesCount == 0) {
        repository.clean();
        yield MessagesEmpty(
          threadMessage: threadMessage,
          parentChannel: parentChannel,
        );
        repository.logger.d("RETURNING FROM LOADING RESPONSES");
        return;
      }
      yield MessagesLoading(
        threadMessage: threadMessage,
        parentChannel: parentChannel,
      );
      List<List> filters = [
        ['thread_id', '=', event.threadId],
      ];
      bool success = await repository.reload(
        queryParams: _makeQueryParams(event),
        filters: filters,
        sortFields: {'creation_date': true},
        limit: _THREAD_MESSAGES_LIMIT,
      );
      if (!success) {
        repository.clean();
        yield ErrorLoadingMessages(
          threadMessage: threadMessage,
          parentChannel: parentChannel,
          force: DateTime.now().toString(),
        );
        return;
      }
      _sortItems();
      yield messagesLoaded;
    } else if (event is LoadSingleMessage) {
      var attempt = 3;
      while (repository.items.any((m) => m.id == _DUMMY_ID) && attempt > 0) {
        await Future.delayed(Duration(milliseconds: 100));
        attempt -= 1;
      }
      final updateParent = await repository.pullOne(_makeQueryParams(event),
          addToItems: threadMessage != null
              ? threadMessage.id == event.threadId
              : false);
      if (updateParent) {
        _updateParentChannel(event.channelId);
      }
      _sortItems();
      messagesBloc.add(ModifyResponsesCount(
        channelId: event.channelId,
        threadId: event.threadId,
      ));
      yield messagesLoaded;
    } else if (event is UpdateThreadMessage) {
      this.threadMessage = event.threadMessage;
      yield messagesLoaded;
    } else if (event is RemoveMessage) {
      messagesBloc.add(ModifyResponsesCount(
        channelId: event.channelId,
        threadId: event.threadId,
      ));
      await repository.delete(
        event.messageId,
        apiSync: !event.onNotify,
        removeFromItems: event.threadId == event.threadId,
        requestBody: _makeQueryParams(event),
      );
      if (repository.items.isEmpty)
        yield MessagesEmpty(
          threadMessage: threadMessage,
          parentChannel: parentChannel,
        );
      else {
        _sortItems();
        yield messagesLoaded;
      }
    } else if (event is SendMessage) {
      final String dummyId = _DUMMY_ID;
      final body = _makeQueryParams(event);
      var tempItem = Message(
        id: dummyId,
        threadId: body['thread_id'],
        userId: ProfileBloc.userId,
        creationDate: DateTime.now().millisecondsSinceEpoch,
        content: MessageTwacode(
          originalStr: body['original_str'],
          prepared: TwacodeParser(body['original_str']).message,
        ),
        reactions: {},
        responsesCount: 0,
        channelId: body['channel_id'],
        username: ProfileBloc.username,
        firstName: ProfileBloc.firstName,
        lastName: ProfileBloc.lastName,
        thumbnail: ProfileBloc.thumbnail,
      );
      repository.pushOne(
        body,
        addToItems: false,
        onError: () {
          this.repository.items.removeWhere((m) => m.id == dummyId);
          this.add(GenerateErrorSendingMessage());
        },
        onSuccess: (message) {
          this.repository.items.removeWhere((m) => m.id == dummyId);
          message.thumbnail = ProfileBloc.thumbnail;
          message.username = ProfileBloc.username;
          message.firstName = ProfileBloc.firstName;
          message.lastName = ProfileBloc.lastName;
          this.repository.items.add(message);
          this.add(FinishLoadingMessages());
          this
              .messagesBloc
              .channelsBloc
              .add(ChangeSelectedChannel(parentChannel.id));
          messagesBloc.add(ModifyResponsesCount(
            channelId: event.channelId,
            threadId: message.threadId,
          ));
          _updateParentChannel(event.channelId, 0);
        },
      );
      this.repository.items.add(tempItem);
      _sortItems();
      yield messagesLoaded;
    } else if (event is FinishLoadingMessages) {
      _sortItems();
      yield messagesLoaded;
    } else if (event is GenerateErrorSendingMessage) {
      yield ErrorSendingMessage(
        messages: repository.items,
        force: DateTime.now().toString(),
        threadMessage: threadMessage,
        parentChannel: parentChannel,
      );
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty(
        threadMessage: threadMessage,
        parentChannel: parentChannel,
      );
    } else if (event is InfinitelyLoadMessages) {
      yield MessagesLoading();
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
    map['company_id'] = map['company_id'] ?? ProfileBloc.selectedCompanyId;
    map['workspace_id'] = map['workspace_id'] ??
        (T == DirectsBloc ? 'direct' : ProfileBloc.selectedWorkspaceId);
    map['limit'] = _THREAD_MESSAGES_LIMIT.toString();
    return map;
  }

  void _sortItems() {
    repository.items.sort(
      (i1, i2) => i2.creationDate.compareTo(i1.creationDate),
    );
  }

  MessagesLoaded get messagesLoaded => MessagesLoaded(
        messageCount: repository.itemsCount,
        force: DateTime.now().toString(),
        messages: repository.items,
        threadMessage: threadMessage,
        parentChannel: parentChannel,
      );

  void _updateParentChannel(String channelId, [int hasUnread = 1]) {
    // print("HAS UNREAD: $hasUnread");
    messagesBloc.channelsBloc.add(ModifyMessageCount(
      channelId: channelId,
      workspaceId:
          T == DirectsBloc ? "direct" : ProfileBloc.selectedWorkspaceId,
      companyId: ProfileBloc.selectedCompanyId,
      hasUnread: hasUnread,
    ));
  }
}
