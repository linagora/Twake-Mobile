import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct.g.dart';

@JsonSerializable(explicitToJson: true)
class Direct {
  @JsonKey(required: true)
  final String id;

  final String name;

  @JsonKey(required: true)
  final List<DirectMember> members;

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

  @JsonKey(required: true, name: 'messages_total')
  final int messageTotal;

  @JsonKey(required: true, name: 'messages_unread')
  final int messageUnread;

  Direct({
    @required this.id,
    this.name,
    this.icon,
    this.description,
    @required this.membersCount,
    @required this.isPrivate,
    @required this.isDirect,
    @required this.lastActivity,
    @required this.messageTotal,
    @required this.members,
    @required this.messageUnread,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// workspaceId is saved on per channel basis in order to save and retrieve
  /// channels from data store later.
  factory Direct.fromJson(Map<String, dynamic> json) => _$DirectFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$DirectToJson(this);
    return map;
  }
}

@JsonSerializable()
class DirectMember {
  @JsonKey(required: true)
  final String userId;

  @JsonKey(required: true)
  final String username;

  @JsonKey(name: 'firstname')
  final String firstName;

  @JsonKey(name: 'lastname')
  final String lastName;

  final String thumbnail;

  // final int timeZoneOffset;

  DirectMember({
    @required this.userId,
    @required this.username,
    this.firstName,
    this.lastName,
    this.thumbnail,
    // this.timeZoneOffset,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// workspaceId is saved on per channel basis in order to save and retrieve
  /// channels from data store later.
  factory DirectMember.fromJson(Map<String, dynamic> json) =>
      _$DirectMemberFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$DirectMemberToJson(this);
    return map;
  }
}
