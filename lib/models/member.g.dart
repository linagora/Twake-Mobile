// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return Member(
    json['id'] as String,
    json['user_id'] as String,
    type: json['type'] as String ?? 'member',
    notificationLevel: json['notification_level'] as String,
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    channelId: json['channel_id'] as String,
    favorite: json['favorite'] as bool,
  )..isSelected = json['is_selected'] as int ?? 0;
}

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'notification_level': instance.notificationLevel,
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
      'user_id': instance.userId,
      'favorite': instance.favorite,
      'is_selected': instance.isSelected,
    };
