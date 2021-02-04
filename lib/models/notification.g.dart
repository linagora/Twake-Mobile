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

WhatsNewItem _$WhatsNewItemFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['company_id', 'workspace_id', 'channel_id']);
  return WhatsNewItem(
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    channelId: json['channel_id'] as String,
  );
}

Map<String, dynamic> _$WhatsNewItemToJson(WhatsNewItem instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
    };
