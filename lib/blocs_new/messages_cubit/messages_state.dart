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
  final Message? parentMessage; // used in threads
  final List<Message> messages;
  final int hash; // sum of hash of all messages in the list

  const MessagesLoadSuccess({
    required this.messages,
    required this.hash,
    this.parentMessage,
  });

  @override
  List<Object?> get props => [hash];
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
  }) : super(messages: messages, hash: hash);
}
