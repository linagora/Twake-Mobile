// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) {
  return NotificationPayload(
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    channelId: json['channel_id'] as String,
    messageId: json['message_id'] as String,
    threadId: json['thread_id'] as String?,
  );
}

Map<String, dynamic> _$NotificationPayloadToJson(
        NotificationPayload instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
      'thread_id': instance.threadId,
      'message_id': instance.messageId,
    };
