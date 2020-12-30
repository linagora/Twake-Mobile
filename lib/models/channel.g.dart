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
    'last_activity',
    'messages_total',
    'messages_unread'
  ]);
  return Channel(
    id: json['id'] as String,
    icon: json['icon'] as String ?? ':thumbsup:',
    description: json['description'] as String,
  )
    ..name = json['name'] as String
    ..membersCount = json['members_count'] as int
    ..lastActivity = json['last_activity'] as int
    ..messagesTotal = json['messages_total'] as int
    ..messagesUnread = json['messages_unread'] as int
    ..workspaceId = json['workspace_id'] as String
    ..isSelected = intToBool(json['is_selected'] as int);
}

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'members_count': instance.membersCount,
      'last_activity': instance.lastActivity,
      'messages_total': instance.messagesTotal,
      'messages_unread': instance.messagesUnread,
      'workspace_id': instance.workspaceId,
      'is_selected': boolToInt(instance.isSelected),
    };
