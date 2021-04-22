import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/threads_bloc/threads_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_event.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/message.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/blocs/messages_bloc/messages_state.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/twacode.dart';

import 'messsage_loaded_type.dart';

export 'package:twake/blocs/messages_bloc/messages_state.dart';
export 'package:twake/blocs/messages_bloc/messages_event.dart';

const _MESSAGE_LIMIT = 30;

class MessagesBloc<T extends BaseChannelBloc>
    extends Bloc<MessagesEvent, MessagesState> {
  final MessagesRepository repository;
  final T channelsBloc;
  final NotificationBloc notificationBloc;

  StreamSubscription _subscription;
  StreamSubscription _notificationSubscription;

  BaseChannel selectedChannel;

  String _previousMessageId;

  MessagesBloc({
    this.repository,
    this.channelsBloc,
    this.notificationBloc,
  }) : super(MessagesEmpty(parentChannel: channelsBloc.repository.selected)) {
    _subscription = channelsBloc.listen((ChannelState state) {
      if (state is ChannelPicked) {
        repository.logger.d('TRIGGERED MESSAGE FETCH');
        repository.logger.w(
            'FETCHING CHANNEL MESSAGES: ${state.selected.name}(${state.selected.id})');
        this.add(LoadMessages());
        selectedChannel = state.selected;
      }
    });
    _notificationSubscription =
        notificationBloc.listen((NotificationState state) async {
      if (T == ChannelsBloc && state is ChannelMessageArrived) {
        // repository.logger.d('GOT CHANNEL MESSAGE: $state');
        // repository.logger.w('SELECTED CHANNEL IS $selectedChannel');
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          channelId: state.data.channelId,
          workspaceId: ProfileBloc.selectedWorkspaceId,
          companyId: ProfileBloc.selectedCompanyId,
        ));
        markChannelRead();
      } else if (T == DirectsBloc && state is DirectMessageArrived) {
        this.add(LoadSingleMessage(
          messageId: state.data.messageId,
          channelId: state.data.channelId,
          companyId: ProfileBloc.selectedCompanyId,
        ));
        markChannelRead();
      } else if (state is DirectThreadMessageArrived && T == DirectsBloc) {
        this.add(ModifyResponsesCount(
          threadId: state.data.threadId,
          channelId: state.data.channelId,
        ));
        markChannelRead();
      } else if (state is ChannelThreadMessageArrived && T == ChannelsBloc) {
        this.add(ModifyResponsesCount(
          threadId: state.data.threadId,
          channelId: state.data.channelId,
        ));
        markChannelRead();
      } else if (state is ThreadMessageNotification) {
        if (T == DirectsBloc && state.data.workspaceId == 'direct') {
          while (selectedChannel.id != state.data.channelId ||
              this.state is! MessagesLoaded) {
            // print('Waiting for the correct channel loading\n'
            // 'COND1: ${selectedChannel.id != state.data.channelId}\n'
            // 'COND2: ${this.state is! MessagesLoaded}');
            await Future.delayed(Duration(milliseconds: 500));
          }
          this.add(SelectMessage(state.data.threadId));
        } else if (T == ChannelsBloc && state.data.workspaceId != 'direct') {
          while (selectedChannel.id != state.data.channelId ||
              this.state is! MessagesLoaded) {
            // print('Waiting for the correct channel loading');
            await Future.delayed(Duration(milliseconds: 500));
          }
          this.add(SelectMessage(state.data.threadId));
        }
        markChannelRead();
      } else if (state is MessageDeleted && selectedChannel != null) {
        this.add(RemoveMessage(
          channelId: state.data.channelId,
          messageId: state.data.messageId,
          onNotify: true,
        ));
      }
    });
    selectedChannel = channelsBloc.repository.selected;
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is LoadMessages) {
      yield MessagesLoading(parentChannel: selectedChannel);
      bool success = await repository.reload(
        queryParams: _makeQueryParams(event),
        filters: [
          ['channel_id', '=', selectedChannel.id],
          ['thread_id', '=', null],
        ],
        sortFields: {'creation_date': false},
        limit: _MESSAGE_LIMIT,
      );
      if (!success) {
        repository.logger.w('FAILED TO FETCH CHANNEL MESSAGES');
        repository.clear();
        yield ErrorLoadingMessages(
          parentChannel: selectedChannel,
          force: DateTime.now().toString(),
        );
        return;
      }
      if (repository.items.isEmpty) {
        yield MessagesEmpty(parentChannel: selectedChannel);
      } else {
        _sortItems();
        yield MessagesLoaded(
          messages: repository.items,
          messageCount: repository.itemsCount,
          parentChannel: selectedChannel,
        );
      }
      // repository.logger.w('SELECTED CHANNEL IS ${selectedChannel.id}');
    } else if (event is LoadMoreMessages) {
      if (_previousMessageId == event.beforeId) return;
      _previousMessageId = event.beforeId;
      yield MoreMessagesLoading(
        messages: repository.items,
        parentChannel: selectedChannel,
      );
      repository
          .loadMore(
        queryParams: _makeQueryParams(event),
        filters: [
          ['channel_id', '=', selectedChannel.id],
          ['creation_date', '<', event.beforeTimeStamp],
          ['thread_id', '=', null],
        ],
        sortFields: {'creation_date': false},
        limit: _MESSAGE_LIMIT,
      )
          .then((success) {
        if (!success) {
          this.add(GenerateErrorLoadingMore());
          return;
        }
        this.add(FinishLoadingMessages(
            messageLoadedType: MessageLoadedType.loadMore));
      });
    } else if (event is FinishLoadingMessages) {
      _sortItems();
      final newState = MessagesLoaded(
          messages: repository.items,
          force: DateTime.now().toString(),
          messageCount: repository.itemsCount,
          parentChannel: selectedChannel,
          messageLoadedType: event.messageLoadedType);

      // repository.logger.d('New state will yield: ${newState != state}');
      yield newState;
    } else if (event is GenerateErrorLoadingMore) {
      yield ErrorLoadingMoreMessages(
        parentChannel: selectedChannel,
        messages: repository.items,
      );
    } else if (event is LoadSingleMessage) {
      repository.logger.d(
          'IS IN CURRENT CHANNEL: ${event.channelId == selectedChannel.id}\n${event.channelId}\n${selectedChannel.id}');

      final updateParent = await repository.pullOne(
        _makeQueryParams(event),
        addToItems: event.channelId == selectedChannel.id,
      );
      if (updateParent) {
        _updateParentChannel(event.channelId);
      }
      _sortItems();
      final newState = MessagesLoaded(
        messages: repository.items,
        messageCount: repository.itemsCount,
        threadMessage: repository.selected,
        force: DateTime.now().toString(),
        parentChannel: selectedChannel,
      );
      repository.logger
          .w("MESSAGES OLD STATE == NEW STATE: ${newState == this.state}");
      yield newState;
    } else if (event is ModifyResponsesCount) {
      var thread = await repository.updateResponsesCount(event.threadId);
      if (thread == null) return;
      if (repository.selected == null) return;

      if (event.channelId == selectedChannel.id) {
        // repository.logger
        // .d('In thread: ${event.threadId == repository.selected.id}');
        thread = event.threadId == repository.selected.id
            ? thread
            : repository.selected;
        final newState = MessagesLoaded(
          threadMessage: thread,
          messages: repository.items,
          messageCount: repository.itemsCount,
          parentChannel: selectedChannel,
          force: DateTime.now().toString(),
        );
        // repository.logger.d('YIELDING STATE: ${newState != this.state}');
        yield newState;
      }
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
            messageLoadedType: MessageLoadedType.afterDelete);

        repository.logger
            .d('Removed message, new state will yield: ${newState != state}');
        yield newState;
      }
    } else if (event is SendMessage) {
      final String dummyId = DUMMY_ID;
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
          this.channelsBloc.add(
                ChangeSelectedChannel(
                  selectedChannel.id,
                  false,
                ),
              );
          _updateParentChannel(selectedChannel.id, 0);
        },
      );
      this.repository.items.add(tempItem);
      _sortItems();
      yield MessagesLoaded(
        messages: repository.items,
        messageCount: repository.itemsCount,
        parentChannel: selectedChannel,
      );
    } else if (event is ClearMessages) {
      await repository.clean();
      yield MessagesEmpty(parentChannel: selectedChannel);
    } else if (event is GenerateErrorSendingMessage) {
      yield ErrorSendingMessage(
        messages: repository.items,
        force: DateTime.now().toString(),
        parentChannel: selectedChannel,
      );
    } else if (event is SelectMessage) {
      ProfileBloc.selectedThreadId = event.messageId;
      repository.select(event.messageId);
      yield MessageSelected(
        threadMessage: repository.selected,
        responsesCount: repository.selected.responsesCount,
        messages: repository.items,
        parentChannel: selectedChannel,
      );
      await repository.updateResponsesCount(event.messageId);
      yield MessageSelected(
        threadMessage: repository.selected,
        responsesCount: repository.selected.responsesCount,
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
    map['company_id'] = map['company_id'] ?? ProfileBloc.selectedCompanyId;
    map['workspace_id'] = map['workspace_id'] ??
        (T == DirectsBloc ? 'direct' : ProfileBloc.selectedWorkspaceId);
    // temporary field for file attachments in directs
    map['fallback_ws_id'] = ProfileBloc.selectedWorkspaceId;
    return map;
  }

  void _updateParentChannel(String channelId, [int hasUnread = 1]) {
    channelsBloc.add(ModifyMessageCount(
      workspaceId: ProfileBloc.selectedWorkspaceId,
      channelId: channelId ?? selectedChannel.id,
      companyId: ProfileBloc.selectedCompanyId,
      hasUnread: hasUnread,
    ));
  }

  void markChannelRead() {
    if (ProfileBloc.selectedChannelId == selectedChannel.id) {
      // just send a request to api, to notify that channel is read
      channelsBloc.repository.select(ProfileBloc.selectedChannelId,
          saveToStore: false,
          apiEndpoint: Endpoint.channelsRead,
          params: {
            "company_id": ProfileBloc.selectedCompanyId,
            "workspace_id": ProfileBloc.selectedWorkspaceId,
            "channel_id": ProfileBloc.selectedChannelId
          });
    }
  }

  void _sortItems() {
    repository.items.sort(
      (i1, i2) => i1.creationDate.compareTo(i2.creationDate),
    );
  }
}
