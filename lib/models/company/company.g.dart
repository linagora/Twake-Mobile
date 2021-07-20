// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return Company(
    id: json['id'] as String,
    name: json['name'] as String,
    totalMembers: json['total_members'] as int? ?? 0,
    logo: json['logo'] as String?,
    selectedWorkspace: json['selected_workspace'] as String?,
    role: _$enumDecode(_$CompanyRoleEnumMap, json['role']),
  );
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'total_members': instance.totalMembers,
      'role': _$CompanyRoleEnumMap[instance.role],
      'selected_workspace': instance.selectedWorkspace,
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

const _$CompanyRoleEnumMap = {
  CompanyRole.owner: 'owner',
  CompanyRole.admin: 'admin',
  CompanyRole.member: 'member',
  CompanyRole.guest: 'guest',
};
