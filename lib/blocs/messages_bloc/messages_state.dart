import 'package:equatable/equatable.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/message.dart';

abstract class MessagesState extends Equatable {
  final BaseChannel parentChannel;
  final Message threadMessage;
  const MessagesState({this.parentChannel, this.threadMessage});
}

class MessagesLoading extends MessagesState {
  const MessagesLoading({BaseChannel parentChannel, Message threadMessage})
      : super(parentChannel: parentChannel, threadMessage: threadMessage);

  @override
  List<Object> get props => [];
}

class MessagesLoaded extends MessagesState {
  final List<Message> messages;
  final int messageCount;
  final Message threadMessage;
  final String force;

  const MessagesLoaded({
    this.messageCount,
    this.force,
    this.messages,
    this.threadMessage,
    BaseChannel parentChannel,
  }) : super(parentChannel: parentChannel, threadMessage: threadMessage);

  @override
  List<Object> get props => [messageCount, messages, parentChannel, force];
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
  const MessagesEmpty({BaseChannel parentChannel, Message threadMessage})
      : super(parentChannel: parentChannel, threadMessage: threadMessage);

  @override
  List<Object> get props => [parentChannel, threadMessage];
}

class MessageSelected extends MessagesLoaded {
  final Message threadMessage;
  final responsesCount;

  const MessageSelected({
    this.threadMessage,
    this.responsesCount,
    List<Message> messages,
    BaseChannel parentChannel,
  }) : super(
          messages: messages,
          messageCount: messages.length,
          threadMessage: threadMessage,
          parentChannel: parentChannel,
        );

  @override
  List<Object> get props => [threadMessage, responsesCount];
}

class ErrorLoadingMessages extends MessagesEmpty {
  final String force;
  const ErrorLoadingMessages(
      {BaseChannel parentChannel, Message threadMessage, this.force})
      : super(parentChannel: parentChannel, threadMessage: threadMessage);

  @override
  List<Object> get props => [parentChannel, threadMessage, force];
}

class ErrorLoadingMoreMessages extends MessagesLoaded {
  final String force;
  const ErrorLoadingMoreMessages({
    this.force,
    BaseChannel parentChannel,
    Message threadMessage,
    List<Message> messages,
  }) : super(
          parentChannel: parentChannel,
          threadMessage: threadMessage,
          messages: messages,
        );

  @override
  List<Object> get props => [parentChannel, threadMessage, force];
}

class ErrorSendingMessage extends MessagesLoaded {
  final String force;
  const ErrorSendingMessage({
    this.force,
    BaseChannel parentChannel,
    Message threadMessage,
    List<Message> messages,
  }) : super(
          parentChannel: parentChannel,
          threadMessage: threadMessage,
          messages: messages,
        );

  @override
  List<Object> get props => [parentChannel, threadMessage, force];
}
