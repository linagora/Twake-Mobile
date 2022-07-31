import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/pinned_info.dart';
import 'package:twake/utils/api_data_transformer.dart';
import 'package:twake/utils/json.dart' as jsn;

import 'reaction.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Message extends BaseModel {
  static const COMPOSITE_FIELDS = [
    'blocks',
    'reactions',
    'files',
    'pinned_info',
    'last_replies',
  ];

  final String id;
  final String threadId;

  @JsonKey(defaultValue: '')
  final String channelId;
  final String userId;

  int createdAt;
  int updatedAt;

  @JsonKey(defaultValue: 0)
  int responsesCount;

  @JsonKey(defaultValue: '')
  String text;

  List<dynamic> blocks;

  List<dynamic>? files;

  MessageSubtype? subtype;

  @JsonKey(defaultValue: const [])
  List<Reaction> reactions;

  @JsonKey(name: 'pinned_info')
  PinnedInfo? pinnedInfo;

  String? username;
  String? firstName;
  String? lastName;
  String? picture;

  String? draft;

  @JsonKey(defaultValue: 1, name: 'is_read')
  int _isRead = 1;

  @JsonKey(defaultValue: Delivery.delivered)
  Delivery delivery;

  @JsonKey(defaultValue: const [], name: 'last_replies')
  List<Message>? _lastReplies;

  List<Message>? get lastReplies => _lastReplies;

  Message? get lastReply => _lastReplies != null && _lastReplies!.isNotEmpty
      ? _lastReplies![_lastReplies!.length - 1]
      : null;
  List<Message>? get last3Replies =>
      _lastReplies != null && _lastReplies!.isNotEmpty
          ? _lastReplies!
              .getRange(
                  (_lastReplies!.length - 4) < 0 ? 0 : _lastReplies!.length - 4,
                  _lastReplies!.length)
              .toList()
          : null;

  int get hash {
    return this.id.hashCode +
        this.text.hashCode +
        this.responsesCount +
        this.reactions.fold(0, (acc, r) => r.name.hashCode + acc) +
        (this.files != null
            ? this.files!.fold(0, (prevFile, file) => file.hashCode + prevFile)
            : 0) +
        this.delivery.hashCode +
        this._isRead +
        (this._lastReplies != null
            ? this
                ._lastReplies!
                .fold(0, (prevReply, reply) => reply.hashCode + prevReply)
            : 0) +
        this.reactions.fold(0, (acc, r) => r.count + acc) as int;
  }

  @override
  int get hashCode {
    return this.id.hashCode +
        this.text.hashCode +
        this.responsesCount +
        this.reactions.fold(0, (acc, r) => r.name.hashCode + acc) +
        (this.files != null
            ? this.files!.fold(0, (prevFile, file) => file.hashCode + prevFile)
            : 0) +
        this.delivery.hashCode +
        this._isRead +
        this.reactions.fold(0, (acc, r) => r.count + acc) +
        (this._lastReplies != null
            ? this
                ._lastReplies!
                .fold(0, (prevReply, reply) => reply.hashCode + prevReply)
            : 0) as int;
  }

  @override
  bool operator ==(other) {
    // don't need to compare blocks, files, reactions fields, createAt
    return (other is Message) &&
        id == other.id &&
        threadId == other.threadId &&
        other.channelId == channelId &&
        other.userId == userId &&
        other.subtype == subtype &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        // other.blocks == blocks &&
        // other.files == files &&
        //other.reactions == reactions &&
        other.username == username &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.picture == picture &&
        other._isRead == _isRead &&
        other.delivery == delivery;
  }

  String get sender {
    if (this.firstName == null || this.lastName == null) {
      return this.username!;
    }
    return '$firstName $lastName';
  }

  @JsonKey(ignore: true)
  bool get isRead => _isRead > 0;

  @JsonKey(ignore: true)
  bool get inThread => id != threadId;

  set isRead(bool val) => _isRead = val ? 1 : 0;

  Message({
    required this.id,
    required this.threadId,
    required this.channelId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.responsesCount,
    this.username,
    required this.text,
    required this.blocks,
    required this.reactions,
    required this.files,
    this.delivery: Delivery.delivered,
    this.firstName,
    this.lastName,
    this.picture,
    this.draft,
    List<Message>? lastReplies = const <Message>[],
  }) : this._lastReplies = lastReplies;

  bool get isOwnerMessage => this.userId == Globals.instance.userId;

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

@HiveType(typeId: TypeConstant.MESSAGE_DELIVERY)
enum Delivery {
  @HiveField(0)
  @JsonValue('in_progress')
  inProgress,

  @HiveField(1)
  @JsonValue('delivered')
  delivered,

  @HiveField(2)
  @JsonValue('failed')
  failed,
}

@HiveType(typeId: TypeConstant.MESSAGE_SUBTYPE)
enum MessageSubtype {
  @HiveField(0)
  @JsonValue('application')
  application,

  @HiveField(1)
  @JsonValue('deleted')
  deleted,

  @HiveField(2)
  @JsonValue('system')
  system
}
