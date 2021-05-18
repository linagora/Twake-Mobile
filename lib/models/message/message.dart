import 'package:json_annotation/json_annotation.dart';
import 'message_content.dart';
import 'reaction.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Message {
  final String id;
  final String? threadId;
  final String channelId;
  final String userId;

  final int creationDate;
  int modificationDate;
  int responsesCount;

  MessageContent content;
  List<Reaction> reactions;

  final String username;
  final String? firstName;
  final String? lastName;
  final String? thumbnail;

  int get hash {
    return this.id.hashCode +
        this.content.originalStr.hashCode +
        this.reactions.fold(0, (acc, r) => r.name.hashCode + acc) +
        this.reactions.fold(0, (acc, r) => r.count + acc) as int;
  }

  String get sender {
    if (this.firstName == null || this.lastName == null) {
      return this.username;
    }
    return '$firstName $lastName';
  }

  Message({
    required this.id,
    this.threadId,
    required this.channelId,
    required this.userId,
    required this.creationDate,
    required this.modificationDate,
    required this.responsesCount,
    required this.username,
    required this.content,
    required this.reactions,
    this.firstName,
    this.lastName,
    this.thumbnail,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
