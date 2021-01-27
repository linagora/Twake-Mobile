import 'package:equatable/equatable.dart';

abstract class MessageEditState extends Equatable {
  const MessageEditState();
}

class NoMessageToEdit extends MessageEditState {
  const NoMessageToEdit();

  @override
  List<Object> get props => [];
}

class MessageEditing extends MessageEditState {
  final Function onMessageEditComplete;
  final String originalStr;

  MessageEditing({
    this.onMessageEditComplete,
    this.originalStr,
  });

  @override
  List<Object> get props => [originalStr];
}
