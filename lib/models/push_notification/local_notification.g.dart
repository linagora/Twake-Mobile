// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalNotification _$LocalNotificationFromJson(Map<String, dynamic> json) {
  return LocalNotification(
    type: _$enumDecode(_$LocalNotificationTypeEnumMap, json['type']),
    payload: json['payload'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$LocalNotificationToJson(LocalNotification instance) =>
    <String, dynamic>{
      'type': _$LocalNotificationTypeEnumMap[instance.type],
      'payload': instance.payload,
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

const _$LocalNotificationTypeEnumMap = {
  LocalNotificationType.message: 'message',
  LocalNotificationType.file: 'file',
};
