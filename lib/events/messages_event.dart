import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  Map<String, dynamic> toMap();
}

class LoadMessages extends MessagesEvent {
  final String threadId;
  const LoadMessages({this.threadId});

  @override
  List<Object> get props => [threadId];

  @override
  Map<String, dynamic> toMap() {
    return {
      'thread_id': threadId,
    };
  }
}

class LoadMoreMessages extends MessagesEvent {
  final String threadId;
  final String beforeId;
  final int beforeTimeStamp;

  const LoadMoreMessages({
    this.threadId,
    this.beforeId,
    this.beforeTimeStamp,
  });

  @override
  List<Object> get props => [beforeId, beforeTimeStamp];

  @override
  Map<String, dynamic> toMap() {
    return {
      'thread_id': threadId,
      'before_message_id': beforeId,
    };
  }
}

class LoadSingleMessage extends MessagesEvent {
  final String messageId;
  final String channelId;
  final String threadId;
  const LoadSingleMessage({this.channelId, this.threadId, this.messageId});

  @override
  List<Object> get props => [messageId, threadId, channelId];

  @override
  Map<String, dynamic> toMap() {
    return {
      'channel_id': channelId,
      'message_id': messageId,
      'thread_id': threadId,
    };
  }
}

class RemoveMessage extends MessagesEvent {
  final String messageId;
  final String channelId;
  final String threadId;
  final bool onNotify;

  const RemoveMessage({
    this.threadId,
    this.messageId,
    this.channelId,
    this.onNotify: false,
  });

  @override
  List<Object> get props => [messageId, threadId];

  @override
  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'thread_id': threadId,
      'channel_id': channelId,
    };
  }
}

class SendMessage extends MessagesEvent {
  final String content;
  final String threadId;

  const SendMessage({this.content, this.threadId});
  @override
  List<Object> get props => [content, threadId];

  @override
  Map<String, dynamic> toMap() {
    return {
      'original_str': content,
      'thread_id': threadId,
    };
  }
}

class ClearMessages extends MessagesEvent {
  const ClearMessages();

  @override
  List<Object> get props => [];

  @override
  Map<String, dynamic> toMap() => {};
}

class SelectMessage extends MessagesEvent {
  final String messageId;
  const SelectMessage(this.messageId);
  @override
  List<Object> get props => [messageId];

  @override
  Map<String, dynamic> toMap() {
    return {
      'thread_id': messageId,
    };
  }
}
