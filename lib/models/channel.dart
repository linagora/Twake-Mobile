import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String icon;

  final String description;

  @JsonKey(required: true, name: 'members_count')
  final int membersCount;

  @JsonKey(required: true, name: 'private')
  final bool isPrivate;

  @JsonKey(required: true, name: 'direct')
  final bool isDirect;

  @JsonKey(required: true, name: 'last_activity')
  final int lastActivity;

  Channel({
    @required this.id,
    @required this.name,
    @required this.icon,
    this.description,
    @required this.membersCount,
    @required this.isPrivate,
    @required this.isDirect,
    @required this.lastActivity,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}
