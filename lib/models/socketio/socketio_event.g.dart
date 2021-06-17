// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socketio_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocketIOEvent _$SocketIOEventFromJson(Map<String, dynamic> json) {
  return SocketIOEvent(
    name: json['name'] as String,
    data: MessageData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SocketIOEventToJson(SocketIOEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data.toJson(),
    };

MessageData _$MessageDataFromJson(Map<String, dynamic> json) {
  return MessageData(
    action: _$enumDecode(_$IOEventActionEnumMap, json['action']),
    messageId: json['message_id'] as String,
    threadId: json['thread_id'] as String?,
  );
}

Map<String, dynamic> _$MessageDataToJson(MessageData instance) =>
    <String, dynamic>{
      'action': _$IOEventActionEnumMap[instance.action],
      'message_id': instance.messageId,
      'thread_id': instance.threadId,
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

const _$IOEventActionEnumMap = {
  IOEventAction.remove: 'remove',
  IOEventAction.update: 'update',
};
