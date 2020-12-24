import 'package:equatable/equatable.dart';
import 'package:twake/models/message.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();

  @override
  List<Object> get props => [];
}

class MessagesLoaded extends MessagesState {
  final List<Message> messages;

  const MessagesLoaded({this.messages});

  @override
  List<Object> get props => [this.messages];
}

class MessagesEmpty extends MessagesState {
  const MessagesEmpty();

  @override
  List<Object> get props => [];
}

class MessageSelected extends MessagesState {
  final Message threadMessage;

  const MessageSelected(this.threadMessage);

  @override
  List<Object> get props => [threadMessage];
}
