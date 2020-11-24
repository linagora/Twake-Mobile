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

  @JsonKey(required: true, name: 'messages_total')
  final int messageTotal;

  @JsonKey(required: true, name: 'messages_unread')
  final int messageUnread;

  @JsonKey(ignore: true)
  String workspaceId;

  Channel({
    @required this.id,
    @required this.name,
    @required this.icon,
    this.description,
    @required this.membersCount,
    @required this.isPrivate,
    @required this.isDirect,
    @required this.lastActivity,
    @required this.messageTotal,
    @required this.messageUnread,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// workspaceId is saved on per channel basis in order to save and retrieve
  /// channels from data store later.
  factory Channel.fromJson(Map<String, dynamic> json, String workspaceId) =>
      _$ChannelFromJson(json)..workspaceId = workspaceId;

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$ChannelToJson(this);
    // Channel Id should be set explicitly, because of ignore JSONKEY
    map['workspaceId'] = this.workspaceId;
    return map;
  }
}
