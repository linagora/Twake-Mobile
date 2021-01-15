import 'package:equatable/equatable.dart';

abstract class SingleMessageState extends Equatable {
  const SingleMessageState();
}

class MessageReady extends SingleMessageState {
  final String id;
  final String threadId;
  final int responsesCount;
  final int creationDate;
  final List<dynamic> content;
  final String text;
  final int charCount;
  final Map<String, dynamic> reactions;
  final String userId;

  const MessageReady({
    this.id,
    this.threadId,
    this.responsesCount,
    this.creationDate,
    this.content,
    this.text,
    this.charCount,
    this.reactions,
    this.userId,
  });

  @override
  List<Object> get props => [id, content, reactions.length, responsesCount];
}
