// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Badge _$BadgeFromJson(Map<String, dynamic> json) => Badge(
      type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
      id: json['id'] as String,
      count: json['count'] as int? ?? 0,
    );

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
      'type': _$BadgeTypeEnumMap[instance.type],
      'id': instance.id,
      'count': instance.count,
    };

const _$BadgeTypeEnumMap = {
  BadgeType.company: 'company',
  BadgeType.workspace: 'workspace',
  BadgeType.channel: 'channel',
  BadgeType.none: 'none',
};
