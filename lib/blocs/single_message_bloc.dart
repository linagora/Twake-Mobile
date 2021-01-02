import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/single_message_event.dart';
import 'package:twake/models/message.dart';
import 'package:twake/states/single_message_state.dart';

export 'package:twake/events/single_message_event.dart';
export 'package:twake/models/message.dart';
export 'package:twake/states/single_message_state.dart';

class SingleMessageBloc extends Bloc<SingleMessageEvent, SingleMessageState> {
  final Message message;
  static final RegExp _userId = RegExp('user_id:([^\s]+)');

  SingleMessageBloc(this.message)
      : super(MessageReady(
          id: message.id,
          responsesCount: message.responsesCount,
          creationDate: message.creationDate,
          content: message.content.prepared,
          text: message.content.originalStr.replaceFirst(_userId, ''),
          charCount: (message.content.originalStr ?? '').length,
          reactions: message.reactions,
          userId: message.userId,
        ));

  @override
  Stream<SingleMessageState> mapEventToState(SingleMessageEvent event) async* {
    if (event is UpdateContent) {
      throw 'Not implemented yet!';
    } else if (event is UpdateReaction) {
      message.updateReactions(userId: event.userId, body: {
        'company_id': event.companyId,
        'channel_id': message.channelId,
        'workspace_id': event.workspaceId,
        'message_id': message.id,
        'thread_id': message.threadId,
        'reaction': event.emojiCode,
      });
      yield messageReady;
    } else if (event is UpdateResponseCount) {
      message.responsesCount += event.modifier;
      yield messageReady;
    }
  }

  MessageReady get messageReady => MessageReady(
        id: message.id,
        responsesCount: message.responsesCount,
        creationDate: message.creationDate,
        content: message.content.prepared,
        text: message.content.originalStr.replaceFirst(_userId, ''),
        charCount: (message.content.originalStr ?? '').length,
        reactions: message.reactions,
        userId: message.userId,
      );
}
