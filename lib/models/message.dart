import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

// TODO document the model

@JsonSerializable(explicitToJson: true)
class Message extends JsonSerializable {
  @JsonKey(required: true)
  String id;

  @JsonKey(name: 'responses_count')
  int responsesCount;

  @JsonKey(required: true)
  String sender;

  @JsonKey(required: true, name: 'creation_date')
  int creationDate;

  @JsonKey(required: true)
  MessageTwacode content;

  // @JsonKey(fromJson: jsonDecode)
  dynamic reactions;
  //
  List<Message> responses;

  Message({
    @required this.id,
    this.responsesCount,
    @required this.sender,
    @required this.creationDate,
    @required this.content,
    this.reactions,
    // this.responses,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class MessageTwacode {
  @JsonKey(required: true, name: 'original_str')
  final String originalStr;

  @JsonKey(required: true)
  final List<dynamic> prepared;

  MessageTwacode({
    @required this.originalStr,
    @required this.prepared,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory MessageTwacode.fromJson(Map<String, dynamic> json) =>
      _$MessageTwacodeFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$MessageTwacodeToJson(this);
}
