// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Direct _$DirectFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'name',
    'messages_total',
    'messages_unread',
    'company_id',
    'members'
  ]);
  return Direct(
    companyId: json['company_id'] as String,
    members: (json['members'] as List)?.map((e) => e as String)?.toList(),
  )
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..icon = json['icon'] as String ?? '👽'
    ..description = json['description'] as String
    ..membersCount = json['members_count'] as int
    ..lastActivity = json['last_activity'] as int ?? 0
    ..messagesTotal = json['messages_total'] as int ?? 0
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
      'messages_total': instance.messagesTotal,
      'messages_unread': instance.messagesUnread,
      'is_selected': instance.isSelected,
      'company_id': instance.companyId,
      'members': instance.members,
    };
