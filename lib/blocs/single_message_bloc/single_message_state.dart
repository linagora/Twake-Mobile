import 'package:equatable/equatable.dart';

abstract class SingleMessageState extends Equatable {
  const SingleMessageState();
}

class MessageReady extends SingleMessageState {
  final String? id;
  final String? threadId;
  final int? responsesCount;
  final int? creationDate;
  final List<dynamic>? content;
  final String? text;
  final int? charCount;
  final List<Map<String, dynamic>>? reactions;
  final int? hash;
  final String? userId;
  final String? sender;
  final String? thumbnail;

  const MessageReady({
    this.id,
    this.threadId,
    this.responsesCount,
    this.creationDate,
    this.content,
    this.text,
    this.charCount,
    this.reactions,
    this.hash,
    this.userId,
    this.sender,
    this.thumbnail,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        responsesCount,
        hash,
      ];
}

class ViewportUpdated extends SingleMessageState {
  final double position;

  ViewportUpdated(this.position);

  List<Object> get props => [position];
}
