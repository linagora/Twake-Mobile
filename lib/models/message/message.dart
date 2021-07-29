import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/utils/api_data_transformer.dart';
import 'package:twake/utils/json.dart' as jsn;

import 'reaction.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Message extends BaseModel {
  static const COMPOSITE_FIELDS = ['blocks', 'reactions'];

  final String id;
  final String threadId;
  final String channelId;
  final String userId;

  int createdAt;
  int updatedAt;

  @JsonKey(defaultValue: 0)
  int responsesCount;

  @JsonKey(defaultValue: '')
  String text;

  List<dynamic> blocks;

  @JsonKey(defaultValue: const [])
  List<Reaction> reactions;

  final String? username;
  final String? firstName;
  final String? lastName;
  final String? picture;

  String? draft;

  @JsonKey(defaultValue: 1, name: 'is_read')
  int _isRead = 1;

  @JsonKey(defaultValue: 1, name: 'is_delivered')
  int _isDelivered = 1;

  int get hash {
    return this.id.hashCode +
        this.text.hashCode +
        this.responsesCount +
        this.reactions.fold(0, (acc, r) => r.name.hashCode + acc) +
        this._isDelivered +
        this._isRead +
        this.reactions.fold(0, (acc, r) => r.count + acc) as int;
  }

  String get sender {
    if (this.firstName == null || this.lastName == null) {
      return this.username!;
    }
    return '$lastName $lastName';
  }

  @JsonKey(ignore: true)
  bool get isRead => _isRead > 0;

  @JsonKey(ignore: true)
  bool get inThread => id != threadId;

  set isRead(bool val) => _isRead = val ? 1 : 0;

  @JsonKey(ignore: true)
  bool get isDelivered => _isDelivered > 0;

  set isDelivered(bool val) => _isDelivered = val ? 1 : 0;

  Message({
    required this.id,
    required this.threadId,
    required this.channelId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.responsesCount,
    required this.username,
    required this.text,
    required this.blocks,
    required this.reactions,
    this.firstName,
    this.lastName,
    this.picture,
    this.draft,
  });

  factory Message.fromJson(
    Map<String, dynamic> json, {
    bool jsonify: true,
    bool transform: false,
    String? channelId,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: COMPOSITE_FIELDS);
    }
    if (transform) {
      json = ApiDataTransformer.message(json: json, channelId: channelId);
    }
    return _$MessageFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$MessageToJson(this);
    json.remove('username');
    json.remove('last_name');
    json.remove('first_name');
    json.remove('picture');
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: COMPOSITE_FIELDS);
    }
    return json;
  }

  Message recent(Message other) {
    if (this.updatedAt > other.updatedAt) return this;

    return other;
  }
}
