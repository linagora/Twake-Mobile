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

  const MessagesLoaded({this.messages, BaseChannel parentChannel})
      : super(parentChannel);

  @override
  List<Object> get props => [messages, parentChannel];
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
  }) : super(messages: messages, parentChannel: parentChannel);

  @override
  List<Object> get props => [threadMessage];
}
