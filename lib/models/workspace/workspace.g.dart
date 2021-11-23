// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) {
  return Workspace(
    id: json['id'] as String,
    name: json['name'] as String,
    logo: json['logo'] as String?,
    companyId: json['company_id'] as String,
    totalMembers: json['total_members'] as int? ?? 0,
    role: _$enumDecodeNullable(_$WorkspaceRoleEnumMap, json['role']) ??
        WorkspaceRole.member,
  );
}

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'company_id': instance.companyId,
      'total_members': instance.totalMembers,
      'role': _$WorkspaceRoleEnumMap[instance.role],
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.moderator: 'moderator',
  WorkspaceRole.member: 'member',
};
