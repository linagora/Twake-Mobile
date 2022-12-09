// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalNotification _$LocalNotificationFromJson(Map<String, dynamic> json) =>
    LocalNotification(
      type: $enumDecode(_$LocalNotificationTypeEnumMap, json['type']),
      payload: json['payload'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LocalNotificationToJson(LocalNotification instance) =>
    <String, dynamic>{
      'type': _$LocalNotificationTypeEnumMap[instance.type],
      'payload': instance.payload,
    };

const _$LocalNotificationTypeEnumMap = {
  LocalNotificationType.message: 'message',
  LocalNotificationType.file: 'file',
};
