import 'package:equatable/equatable.dart';
import 'package:twake/models/message/message.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();

  @override
  List<Object?> get props => [];
}

class MessagesLoadSuccess extends MessagesState {
  final List<Message> messages;
  final int hash; // sum of hash of all messages in the list
  final bool endOfHistory;

  const MessagesLoadSuccess({
    required this.messages,
    required this.hash,
    this.endOfHistory: false,
  });

  @override
  List<Object?> get props => [hash];
}

class MessageSendInProgress extends MessagesLoadSuccess {
  final List<Message> messages;
  final int hash; // sum of hash of all messages in the list

  const MessageSendInProgress({
    required this.messages,
    required this.hash,
  }) : super(messages: messages, hash: hash);
}

class NoMessagesFound extends MessagesLoadSuccess {
  NoMessagesFound() : super(messages: <Message>[], hash: 0);

  @override
  List<Object?> get props => const [];
}

class MessageEditInProgress extends MessagesLoadSuccess {
  final Message message;

  const MessageEditInProgress({
    required this.message,
    required List<Message> messages,
    required int hash,
    Message? parentMessage,
  }) : super(messages: messages, hash: hash);

  @override
  List<Object?> get props => [message];
}

class MessagesLoadInProgress extends MessagesState {
  const MessagesLoadInProgress();

  @override
  List<Object?> get props => [];
}

class MessagesBeforeLoadInProgress extends MessagesLoadSuccess {
  const MessagesBeforeLoadInProgress({
    required List<Message> messages,
    required int hash,
    Message? parentMessage,
  }) : super(messages: messages, hash: hash);
}

class MessagesAroundPinnedLoadSuccess extends MessagesLoadSuccess {
  final Message pinnedMessage;

  MessagesAroundPinnedLoadSuccess(
      {required List<Message> messages,
      required int hash,
      required bool endOfHistory,
      required this.pinnedMessage})
      : super(messages: messages, hash: hash);

    @override
  List<Object?> get props => [pinnedMessage];
}

class MessageLatestSuccess extends MessagesLoadSuccess {
  final Message latestMessage;

  MessageLatestSuccess(
      {required List<Message> messages,
      required int hash,
      required this.latestMessage})
      : super(messages: messages, hash: hash);

  @override
  List<Object?> get props => [latestMessage];
}
