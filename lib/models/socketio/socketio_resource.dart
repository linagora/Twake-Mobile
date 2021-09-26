import 'package:json_annotation/json_annotation.dart';

part 'socketio_resource.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SocketIOResource {
  final ResourceAction action;
  final ResourceType type;
  final Map<String, dynamic> resource;

  const SocketIOResource({
    required this.action,
    required this.type,
    required this.resource,
  });

  factory SocketIOResource.fromJson({required Map<String, dynamic> json}) {
    return _$SocketIOResourceFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SocketIOResourceToJson(this);
  }
}

enum ResourceType {
  @JsonValue('message')
  message,
  @JsonValue('channel')
  channel,
  @JsonValue('channels')
  channels,
  @JsonValue('channel_member')
  channelMember,
  @JsonValue('channel_activity')
  channelActivity,
  @JsonValue('user_notification_badges')
  userNotificationBadges,
  @JsonValue('notification:desktop')
  notificationDesktop, // ignore this one for now
}

enum ResourceAction {
  @JsonValue('created')
  created,
  @JsonValue('updated')
  updated,
  @JsonValue('saved')
  saved,
  @JsonValue('deleted')
  deleted,
  @JsonValue('event')
  event, // ignore this one for now
}
