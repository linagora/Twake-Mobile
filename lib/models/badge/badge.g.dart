// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeTypeAdapter extends TypeAdapter<BadgeType> {
  @override
  final int typeId = 11;

  @override
  BadgeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BadgeType.company;
      case 1:
        return BadgeType.workspace;
      case 2:
        return BadgeType.channel;
      case 3:
        return BadgeType.none;
      default:
        return BadgeType.company;
    }
  }

  @override
  void write(BinaryWriter writer, BadgeType obj) {
    switch (obj) {
      case BadgeType.company:
        writer.writeByte(0);
        break;
      case BadgeType.workspace:
        writer.writeByte(1);
        break;
      case BadgeType.channel:
        writer.writeByte(2);
        break;
      case BadgeType.none:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
