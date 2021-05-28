// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socketio_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketIORoom _$SocketIORoomFromJson(Map<String, dynamic> json) {
  return SocketIORoom(
    key: json['key'] as String,
    type: _$enumDecode(_$RoomTypeEnumMap, json['type']),
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$SocketIORoomToJson(SocketIORoom instance) =>
    <String, dynamic>{
      'key': instance.key,
      'type': _$RoomTypeEnumMap[instance.type],
      'id': instance.id,
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

const _$RoomTypeEnumMap = {
  RoomType.channel: 'channel',
  RoomType.direct: 'direct',
  RoomType.channelsList: 'channels_list',
  RoomType.directs_list: 'directs_list',
  RoomType.notifications: 'notifications',
};
