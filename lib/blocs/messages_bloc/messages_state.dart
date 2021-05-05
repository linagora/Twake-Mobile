import 'package:equatable/equatable.dart';
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/message.dart';

import 'messsage_loaded_type.dart';

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
  final MessageLoadedType messageLoadedType;

  const MessagesLoaded({
    this.messageCount,
    this.force,
    this.messages,
    this.threadMessage,
    this.messageLoadedType = MessageLoadedType.normal,
    BaseChannel parentChannel,
  }) : super(parentChannel: parentChannel, threadMessage: threadMessage);

  @override
  List<Object> get props =>
      [messageCount, messages, parentChannel, force, messageLoadedType];
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
  final String force;
  const MessagesEmpty(
      {BaseChannel parentChannel, Message threadMessage, this.force})
      : super(parentChannel: parentChannel, threadMessage: threadMessage);

  @override
  List<Object> get props => [parentChannel, threadMessage, force];
}

class MessageSelected extends MessagesLoaded {
  final Message threadMessage;
  final responsesCount;

  const MessageSelected({
    this.threadMessage,
    this.responsesCount,
    List<Message> messages,
    BaseChannel parentChannel,
    String force,
  }) : super(
          messages: messages,
          messageCount: messages.length,
          threadMessage: threadMessage,
          parentChannel: parentChannel,
          force: force,
        );

  @override
  List<Object> get props => [threadMessage, responsesCount, force];
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
