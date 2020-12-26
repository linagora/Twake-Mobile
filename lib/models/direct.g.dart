// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Direct _$DirectFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'company_id',
    'members',
    'members_count',
    'private',
    'last_activity',
    'messages_total',
    'messages_unread'
  ]);
  return Direct(
    id: json['id'] as String,
    companyId: json['company_id'] as String,
  )
    ..isSelected = json['isSelected'] as bool
    ..name = json['name'] as String
    ..members = (json['members'] as List)?.map((e) => e as String)?.toList()
    ..icon = json['icon'] as String
    ..description = json['description'] as String
    ..membersCount = json['members_count'] as int
    ..isPrivate = json['private'] as bool
    ..lastActivity = json['last_activity'] as int
    ..messageTotal = json['messages_total'] as int
    ..messageUnread = json['messages_unread'] as int;
}

Map<String, dynamic> _$DirectToJson(Direct instance) => <String, dynamic>{
      'isSelected': instance.isSelected,
      'id': instance.id,
      'name': instance.name,
      'company_id': instance.companyId,
      'members': instance.members,
      'icon': instance.icon,
      'description': instance.description,
      'members_count': instance.membersCount,
      'private': instance.isPrivate,
      'last_activity': instance.lastActivity,
      'messages_total': instance.messageTotal,
      'messages_unread': instance.messageUnread,
    };
