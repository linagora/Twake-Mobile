import 'package:equatable/equatable.dart';
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
  final String senderId;

  const MessageReady({
    this.id,
    this.responsesCount,
    this.creationDate,
    this.content,
    this.reactions,
    this.senderId,
  });

  @override
  // TODO: implement props
  List<Object> get props => [id, content, reactions, responsesCount];
}
