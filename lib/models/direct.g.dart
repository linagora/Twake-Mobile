// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Direct _$DirectFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'members',
    'members_count',
    'private',
    'direct',
    'last_activity',
    'messages_total',
    'messages_unread'
  ]);
  return Direct(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    description: json['description'] as String,
    membersCount: json['members_count'] as int,
    isPrivate: json['private'] as bool,
    isDirect: json['direct'] as bool,
    lastActivity: json['last_activity'] as int,
    messageTotal: json['messages_total'] as int,
    members: (json['members'] as List)
        ?.map((e) =>
            e == null ? null : DirectMember.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    messageUnread: json['messages_unread'] as int,
  );
}

Map<String, dynamic> _$DirectToJson(Direct instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'members': instance.members?.map((e) => e?.toJson())?.toList(),
      'icon': instance.icon,
      'description': instance.description,
      'members_count': instance.membersCount,
      'private': instance.isPrivate,
      'direct': instance.isDirect,
      'last_activity': instance.lastActivity,
      'messages_total': instance.messageTotal,
      'messages_unread': instance.messageUnread,
    };

DirectMember _$DirectMemberFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['userId', 'username']);
  return DirectMember(
    userId: json['userId'] as String,
    username: json['username'] as String,
    firstName: json['firstname'] as String,
    lastName: json['lastname'] as String,
    thumbnail: json['thumbnail'] as String,
    timeZoneOffset: json['timeZoneOffset'] as int,
  );
}

Map<String, dynamic> _$DirectMemberToJson(DirectMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'thumbnail': instance.thumbnail,
      'timeZoneOffset': instance.timeZoneOffset,
    };
