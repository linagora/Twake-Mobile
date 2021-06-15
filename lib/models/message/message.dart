import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/utils/json.dart' as jsn;

import 'message_content.dart';
import 'reaction.dart';

export 'message_content.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Message extends BaseModel {
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
  String? draft;

  @JsonKey(defaultValue: 1, name: 'is_read')
  int _isRead = 1;

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

  @JsonKey(ignore: true)
  bool get isRead => _isRead > 0;

  set isRead(bool val) => _isRead = val ? 1 : 0;

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
    this.draft,
  });

  factory Message.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: true,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: COMPOSITE_FIELDS);
    }
    return _$MessageFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$MessageToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: COMPOSITE_FIELDS);
    }
    return json;
  }
}
