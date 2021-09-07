// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socketio_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketIOResource _$SocketIOResourceFromJson(Map<String, dynamic> json) {
  return SocketIOResource(
    action: _$enumDecode(_$ResourceActionEnumMap, json['action']),
    type: _$enumDecode(_$ResourceTypeEnumMap, json['type']),
    resource: json['resource'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$SocketIOResourceToJson(SocketIOResource instance) =>
    <String, dynamic>{
      'action': _$ResourceActionEnumMap[instance.action],
      'type': _$ResourceTypeEnumMap[instance.type],
      'resource': instance.resource,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

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
  ResourceType.channelMember: 'channel_member',
  ResourceType.channelActivity: 'channel_activity',
  ResourceType.userNotificationBadges: 'user_notification_badges',
  ResourceType.notificationDesktop: 'notification:desktop',
};
