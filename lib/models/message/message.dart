import 'package:json_annotation/json_annotation.dart';

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
}
