// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Context _$ContextFromJson(Map<String, dynamic> json) => Context(
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      channelId: json['channel_id'] as String,
      companyId: json['company_id'] as String,
      fileId: json['file_id'] as String,
      id: json['id'] as String,
      messageFileId: json['message_file_id'] as String,
      messageId: json['message_id'] as String,
      threadId: json['thread_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );

Map<String, dynamic> _$ContextToJson(Context instance) => <String, dynamic>{
      'target_type': instance.targetType,
      'company_id': instance.companyId,
      'target_id': instance.targetId,
      'id': instance.id,
      'channel_id': instance.channelId,
      'file_id': instance.fileId,
      'message_file_id': instance.messageFileId,
      'message_id': instance.messageId,
      'thread_id': instance.threadId,
      'workspace_id': instance.workspaceId,
    };
