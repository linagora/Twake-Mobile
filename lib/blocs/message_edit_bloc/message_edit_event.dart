import 'package:equatable/equatable.dart';

abstract class MessageEditEvent extends Equatable {
  const MessageEditEvent();
}

class CancelMessageEdit extends MessageEditEvent {
  const CancelMessageEdit();

  @override
  List<Object> get props => [];
}

class EditMessage extends MessageEditEvent {
  final Function onMessageEditComplete;
  final String originalStr;

  const EditMessage({this.onMessageEditComplete, this.originalStr});

  @override
  List<Object> get props => [originalStr];
}

class GetMentionableUsers extends MessageEditEvent {
  final String searchTerm;

  const GetMentionableUsers(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];
}
