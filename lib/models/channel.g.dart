// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'name',
    'icon',
    'members_count',
    'private',
    'direct',
    'last_activity'
  ]);
  return Channel(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    description: json['description'] as String,
    membersCount: json['members_count'] as int,
    isPrivate: json['private'] as bool,
    isDirect: json['direct'] as bool,
    lastActivity: json['last_activity'] as int,
  );
}

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'members_count': instance.membersCount,
      'private': instance.isPrivate,
      'direct': instance.isDirect,
      'last_activity': instance.lastActivity,
    };
