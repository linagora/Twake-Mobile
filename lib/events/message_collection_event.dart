import 'package:equatable/equatable.dart';

abstract class MessageCollectionEvent extends Equatable {
  const MessageCollectionEvent();
}

class LoadChannelMessages extends MessageCollectionEvent {
  final channelId;
  const LoadChannelMessages(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class LoadMessage extends MessageCollectionEvent {
  final String channelId;
  final String messageId;
  final String threadId;
  const LoadMessage({this.channelId, this.threadId, this.messageId});

  @override
  List<Object> get props => [messageId, channelId, threadId];
}

class RemoveMessage extends MessageCollectionEvent {
  final String channelId;
  final String messageId;
  final String threadId;

  const RemoveMessage({this.channelId, this.threadId, this.messageId});

  @override
  List<Object> get props => [channelId, messageId, threadId];
}

class SendMessage extends MessageCollectionEvent {
  final String channelId;
  final String content;
  final String threadId;

  const SendMessage({this.channelId, this.content, this.threadId});
  @override
  // TODO: implement props
  List<Object> get props => [channelId, content, threadId];
}
