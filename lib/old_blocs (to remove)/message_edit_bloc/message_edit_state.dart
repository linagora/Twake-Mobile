import 'package:equatable/equatable.dart';
import 'package:twake/models/user.dart';

abstract class MessageEditState extends Equatable {
  const MessageEditState();
}

class NoMessageToEdit extends MessageEditState {
  const NoMessageToEdit();

  @override
  List<Object> get props => [];
}

class MessageEditing extends MessageEditState {
  final Function? onMessageEditComplete;
  final String? originalStr;
  final List<User>? mentionable;

  MessageEditing({
    this.onMessageEditComplete,
    this.originalStr,
    this.mentionable,
  });

  @override
  List<Object?> get props => [originalStr, mentionable];
}
