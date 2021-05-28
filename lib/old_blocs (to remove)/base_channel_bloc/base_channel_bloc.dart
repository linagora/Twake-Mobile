import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc/channel_event.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/blocs/channels_bloc/channel_state.dart';

export 'package:twake/blocs/channels_bloc/channel_event.dart';
export 'package:twake/blocs/channels_bloc/channel_state.dart';

abstract class BaseChannelBloc extends Bloc<ChannelsEvent, ChannelState?> {
  final CollectionRepository<BaseChannel?>? repository;
  String? selectedParentId;
  String? selectedBeforeId;

  BaseChannelBloc({
    this.repository,
    ChannelState? initState,
  }) : super(initState);

  @override
  Stream<ChannelState> mapEventToState(ChannelsEvent event) async* {
    yield ChannelsEmpty();
  }

  Future<void> updateMessageCount(ModifyMessageCount event) async {
    final ch = await repository!.getItemById(event.channelId);
    if (ch != null) {
      // ch.messagesTotal += event.totalModifier ?? 0;
      ch.hasUnread = event.hasUnread ?? 1;
      ch.messagesUnread += event.unreadModifier ?? 0;
      ch.lastActivity =
          event.timeStamp ?? DateTime.now().millisecondsSinceEpoch;
      repository!.saveOne(ch);
    }
  }

  Future<void> updateChannelState(ModifyChannelState event) async {
    final ch = await repository!.getItemById(event.channelId);
    if (ch != null) {
      ch.hasUnread = 1;
      if (event.threadId != null || event.messageId != null) {
        ch.messagesUnread += 1;
      }
      repository!.saveOne(ch);
    }
  }
}
