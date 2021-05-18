import 'package:json_annotation/json_annotation.dart';
import 'package:twake/utils/json.dart';

import 'message_content.dart';
import 'reaction.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Message {
  static const COMPOSITE_FIELDS = ['content', 'reactions'];

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
  final String? firstname;
  final String? lastname;
  final String? thumbnail;

  int get hash {
    return this.id.hashCode +
        this.content.originalStr.hashCode +
        this.reactions.fold(0, (acc, r) => r.name.hashCode + acc) +
        this.reactions.fold(0, (acc, r) => r.count + acc) as int;
  }

  String get sender {
    if (this.firstname == null || this.lastname == null) {
      return this.username;
    }
    return '$firstname $lastname';
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
    this.firstname,
    this.lastname,
    this.thumbnail,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    json = jsonify(json: json, keys: COMPOSITE_FIELDS);
    return _$MessageFromJson(json);
  }

  Map<String, dynamic> toJson() {
    final json = _$MessageToJson(this);
    return stringify(json: json, keys: COMPOSITE_FIELDS);
  }
}
