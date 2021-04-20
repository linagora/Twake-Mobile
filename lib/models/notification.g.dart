// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageNotification _$MessageNotificationFromJson(Map<String, dynamic> json) {
  return MessageNotification(
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    channelId: json['channel_id'] as String,
    threadId: json['thread_id'] as String,
    messageId: json['message_id'] as String,
  );
}

Map<String, dynamic> _$MessageNotificationToJson(
        MessageNotification instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
      'thread_id': instance.threadId,
      'message_id': instance.messageId,
    };

SocketChannelUpdateNotification _$SocketChannelUpdateNotificationFromJson(
    Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return SocketChannelUpdateNotification(
    channelId: json['id'] as String,
    workspaceId: json['workspace_id'] as String,
    companyId: json['company_id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    icon: json['icon'] as String,
    visibility: json['visibility'] as String,
    lastMessage: json['last_message'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$SocketChannelUpdateNotificationToJson(
        SocketChannelUpdateNotification instance) =>
    <String, dynamic>{
      'id': instance.channelId,
      'workspace_id': instance.workspaceId,
      'company_id': instance.companyId,
      'icon': instance.icon,
      'name': instance.name,
      'description': instance.description,
      'visibility': instance.visibility,
      'last_message': instance.lastMessage,
    };

SocketDirectUpdateNotification _$SocketDirectUpdateNotificationFromJson(
    Map<String, dynamic> json) {
  return SocketDirectUpdateNotification(
    directId: json['directId'] as String,
    lastActivity: json['lastActivity'] as int,
    lastMessage: json['lastMessage'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$SocketDirectUpdateNotificationToJson(
        SocketDirectUpdateNotification instance) =>
    <String, dynamic>{
      'directId': instance.directId,
      'lastActivity': instance.lastActivity,
      'lastMessage': instance.lastMessage,
    };

SocketMessageUpdateNotification _$SocketMessageUpdateNotificationFromJson(
    Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['channel_id']);
  return SocketMessageUpdateNotification(
    channelId: json['channel_id'] as String,
    threadId: json['thread_id'] as String,
    messageId: json['message_id'] as String,
  );
}

Map<String, dynamic> _$SocketMessageUpdateNotificationToJson(
        SocketMessageUpdateNotification instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
      'thread_id': instance.threadId,
      'message_id': instance.messageId,
    };

WhatsNewItem _$WhatsNewItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['company_id', 'workspace_id', 'channel_id']);
  return WhatsNewItem(
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    channelId: json['channel_id'] as String,
    threadId: json['thread_id'] as String,
    messageId: json['message_id'] as String,
  );
}

Map<String, dynamic> _$WhatsNewItemToJson(WhatsNewItem instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
      'thread_id': instance.threadId,
      'message_id': instance.messageId,
    };
