import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

// TODO document the model

@JsonSerializable(explicitToJson: true)
class Message extends JsonSerializable {
  @JsonKey(required: true)
  final String id;

  @JsonKey(name: 'responses_count')
  final int responsesCount;

  @JsonKey(required: true)
  final Sender sender;

  @JsonKey(required: true, name: 'creation_date')
  final int creationDate;

  @JsonKey(required: true)
  final MessageTwacode content;

  final dynamic reactions;

  final List<Message> responses;

  @JsonKey(ignore: true)
  String channelId;

  Message({
    @required this.id,
    this.responsesCount,
    this.sender,
    this.creationDate,
    this.content,
    this.reactions,
    this.responses,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// channelId is saved on per message basis in order to save and retrieve
  /// messages from data store later.
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$MessageToJson(this);
    // Channel Id should be set explicitly, because of ignore JSONKEY
    map['channelId'] = this.channelId;
    return map;
  }
}

@JsonSerializable()
class MessageTwacode {
  @JsonKey(name: 'original_str')
  final String originalStr;

  // @JsonKey(required: true)
  final List<dynamic> prepared;

  MessageTwacode({
    this.originalStr,
    this.prepared,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory MessageTwacode.fromJson(Map<String, dynamic> json) =>
      _$MessageTwacodeFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$MessageTwacodeToJson(this);
}

@JsonSerializable()
class Sender {
  @JsonKey(required: true)
  final String username;

  final String img;

  final String id;

  @JsonKey(name: 'firstname')
  final String firstName;

  @JsonKey(name: 'lastname')
  final String lastName;

  Sender({
    @required this.username,
    this.img,
    this.id,
    this.firstName,
    this.lastName,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$SenderToJson(this);
}
