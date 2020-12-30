// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseChannel _$BaseChannelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'name',
    'members_count',
    'last_activity',
    'messages_total',
    'messages_unread'
  ]);
  return BaseChannel(
    id: json['id'] as String,
  )
    ..name = json['name'] as String
    ..icon = json['icon'] as String
    ..description = json['description'] as String
    ..membersCount = json['members_count'] as int
    ..lastActivity = json['last_activity'] as int
    ..messagesTotal = json['messages_total'] as int
    ..messagesUnread = json['messages_unread'] as int
    ..isSelected = intToBool(json['is_selected'] as int);
}

Map<String, dynamic> _$BaseChannelToJson(BaseChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'members_count': instance.membersCount,
      'last_activity': instance.lastActivity,
      'messages_total': instance.messagesTotal,
      'messages_unread': instance.messagesUnread,
      'is_selected': boolToInt(instance.isSelected),
    };
