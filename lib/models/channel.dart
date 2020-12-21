import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends JsonSerializable {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  String name;

  @JsonKey(required: true)
  final String icon;

  final String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(required: true, name: 'private')
  final bool isPrivate;

  @JsonKey(required: true, name: 'last_activity')
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  int messagesTotal;

  @JsonKey(required: true, name: 'messages_unread')
  int messagesUnread;

  // TODO get from api
  @JsonKey(ignore: true)
  String workspaceId;

  Channel({
    this.id,
    this.icon,
    this.description,
    this.isPrivate,
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
