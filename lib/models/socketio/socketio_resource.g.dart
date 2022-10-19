// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socketio_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketIOResource _$SocketIOResourceFromJson(Map<String, dynamic> json) =>
    SocketIOResource(
      action: $enumDecode(_$ResourceActionEnumMap, json['action']),
      type: $enumDecode(_$ResourceTypeEnumMap, json['type']),
      resource: json['resource'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SocketIOResourceToJson(SocketIOResource instance) =>
    <String, dynamic>{
      'action': _$ResourceActionEnumMap[instance.action],
      'type': _$ResourceTypeEnumMap[instance.type],
      'resource': instance.resource,
    };

const _$ResourceActionEnumMap = {
  ResourceAction.created: 'created',
  ResourceAction.updated: 'updated',
  ResourceAction.saved: 'saved',
  ResourceAction.deleted: 'deleted',
  ResourceAction.event: 'event',
};

const _$ResourceTypeEnumMap = {
  ResourceType.message: 'message',
  ResourceType.channel: 'channel',
  ResourceType.channels: 'channels',
  ResourceType.channelMember: 'channel_member',
  ResourceType.channelActivity: 'channel_activity',
  ResourceType.userNotificationBadges: 'user_notification_badges',
  ResourceType.notificationDesktop: 'notification:desktop',
  ResourceType.userOnlineStatus: 'user:online',
};
