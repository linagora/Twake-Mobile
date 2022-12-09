// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      id: json['id'] as String,
      name: json['name'] as String,
      totalMembers: json['total_members'] as int? ?? 0,
      logo: json['logo'] as String?,
      selectedWorkspace: json['selected_workspace'] as String?,
      role: $enumDecode(_$CompanyRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'total_members': instance.totalMembers,
      'role': _$CompanyRoleEnumMap[instance.role],
      'selected_workspace': instance.selectedWorkspace,
    };

const _$CompanyRoleEnumMap = {
  CompanyRole.owner: 'owner',
  CompanyRole.admin: 'admin',
  CompanyRole.member: 'member',
  CompanyRole.guest: 'guest',
};
