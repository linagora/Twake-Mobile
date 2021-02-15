import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class MessageNotification extends NotificationData {
  @JsonKey(name: 'company_id')
  final String companyId;
  @JsonKey(name: 'workspace_id')
  final String workspaceId;
  @JsonKey(name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'message_id')
  final String messageId;

  MessageNotification({
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
    this.messageId,
  });

  factory MessageNotification.fromJson(Map<String, dynamic> json) =>
      _$MessageNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$MessageNotificationToJson(this);
}

abstract class NotificationData {
  const NotificationData();
}

@JsonSerializable()
class SocketChannelUpdateNotification extends NotificationData {
  @JsonKey(required: true, name: 'id')
  final String channelId;
  @JsonKey(name: 'workspace_id')
  final String workspaceId;
  @JsonKey(name: 'company_id')
  final String companyId;
  final String icon;
  final String name;
  final String description;
  final String visibility;

  SocketChannelUpdateNotification({
    this.channelId,
    this.workspaceId,
    this.companyId,
    this.name,
    this.description,
    this.icon,
    this.visibility,
  });

  factory SocketChannelUpdateNotification.fromJson(Map<String, dynamic> json) =>
      _$SocketChannelUpdateNotificationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SocketChannelUpdateNotificationToJson(this);
}

@JsonSerializable()
class SocketMessageUpdateNotification extends NotificationData {
  @JsonKey(required: true, name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'message_id')
  final String messageId;

  SocketMessageUpdateNotification({
    this.channelId,
    this.threadId,
    this.messageId,
  });

  factory SocketMessageUpdateNotification.fromJson(Map<String, dynamic> json) =>
      _$SocketMessageUpdateNotificationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SocketMessageUpdateNotificationToJson(this);
}

@JsonSerializable()
class WhatsNewItem extends NotificationData {
  @JsonKey(required: true, name: 'company_id')
  final String companyId;
  @JsonKey(required: true, name: 'workspace_id')
  final String workspaceId;
  @JsonKey(required: true, name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'message_id')
  final String messageId;

  WhatsNewItem({
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
    this.messageId,
  });

  factory WhatsNewItem.fromJson(Map<String, dynamic> json) =>
      _$WhatsNewItemFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsNewItemToJson(this);
}
