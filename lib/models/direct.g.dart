// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Direct _$DirectFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name', 'company_id', 'members']);
  return Direct(
    companyId: json['company_id'] as String,
    members: (json['members'] as List)?.map((e) => e as String)?.toList(),
  )
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..icon = json['icon'] as String ?? '👽'
    ..description = json['description'] as String
    ..membersCount = json['members_count'] as int ?? 0
    ..lastActivity = json['last_activity'] as int ?? 0
    ..lastMessage = json['last_message'] as Map<String, dynamic> ?? {}
    ..lastAccess = json['user_last_access'] as int ?? 0
    ..hasUnread = boolToInt(json['has_unread'])
    ..messagesUnread = json['messages_unread'] as int ?? 0
    ..isSelected = json['is_selected'] as int ?? 0;
}

Map<String, dynamic> _$DirectToJson(Direct instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'members_count': instance.membersCount,
      'last_activity': instance.lastActivity,
      'last_message': instance.lastMessage,
      'user_last_access': instance.lastAccess,
      'has_unread': boolToInt(instance.hasUnread),
      'messages_unread': instance.messagesUnread,
      'is_selected': instance.isSelected,
      'company_id': instance.companyId,
      'members': instance.members,
    };
