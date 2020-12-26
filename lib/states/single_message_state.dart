import 'package:equatable/equatable.dart';
import 'package:twake/models/sender.dart';
import 'package:twake/models/twacode.dart';

abstract class SingleMessageState extends Equatable {
  const SingleMessageState();
}

class MessageReady extends SingleMessageState {
  final String id;
  final int responsesCount;
  final int creationDate;
  final MessageTwacode content;
  final Map<String, dynamic> reactions;
  final Sender sender;

  const MessageReady({
    this.id,
    this.responsesCount,
    this.creationDate,
    this.content,
    this.reactions,
    this.sender,
  });

  @override
  List<Object> get props => [id, content, reactions, responsesCount];
}
