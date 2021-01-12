import 'package:equatable/equatable.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/message.dart';

abstract class MessagesState extends Equatable {
  final BaseChannel parentChannel;
  const MessagesState(this.parentChannel);
}

class MessagesLoading extends MessagesState {
  const MessagesLoading({BaseChannel parentChannel}) : super(parentChannel);

  @override
  List<Object> get props => [];
}

class MessagesLoaded extends MessagesState {
  final List<Message> messages;
  final int messageCount;

  const MessagesLoaded({
    this.messageCount,
    this.messages,
    BaseChannel parentChannel,
  }) : super(parentChannel);

  @override
  List<Object> get props => [messageCount, messages, parentChannel];
}

class MoreMessagesLoading extends MessagesLoaded {
  const MoreMessagesLoading({
    List<Message> messages,
    BaseChannel parentChannel,
  }) : super(
          messageCount: messages.length,
          messages: messages,
          parentChannel: parentChannel,
        );
}

class MessagesEmpty extends MessagesState {
  const MessagesEmpty({BaseChannel parentChannel}) : super(parentChannel);

  @override
  List<Object> get props => [parentChannel];
}

class MessageSelected extends MessagesLoaded {
  final Message threadMessage;

  const MessageSelected({
    this.threadMessage,
    List<Message> messages,
    BaseChannel parentChannel,
  }) : super(
          messages: messages,
          messageCount: messages.length,
          parentChannel: parentChannel,
        );

  @override
  List<Object> get props => [threadMessage];
}
