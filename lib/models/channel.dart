import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  String name;

  @JsonKey(required: true, defaultValue: ':thumbsup:')
  final String icon;

  final String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(required: true, name: 'last_activity')
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  int messagesTotal;

  @JsonKey(required: true, name: 'messages_unread')
  int messagesUnread;

  @JsonKey(name: 'workspace_id')
  String workspaceId;

  @JsonKey(
    defaultValue: false,
    name: 'is_selected',
    fromJson: intToBool,
    toJson: boolToInt,
  )
  bool isSelected;

  Channel({
    this.id,
    this.icon,
    this.description,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    return _$ChannelToJson(this);
  }
}
