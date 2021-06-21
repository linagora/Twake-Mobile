// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return Badge(
    type: _$enumDecode(_$BadgeTypeEnumMap, json['type']),
    id: json['id'] as String,
    count: json['count'] as int,
  );
}

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
      'type': _$BadgeTypeEnumMap[instance.type],
      'id': instance.id,
      'count': instance.count,
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

const _$BadgeTypeEnumMap = {
  BadgeType.company: 'company',
  BadgeType.workspace: 'workspace',
  BadgeType.channel: 'channel',
  BadgeType.none: 'none',
};
