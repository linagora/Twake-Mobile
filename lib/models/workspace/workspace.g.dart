// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) => Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      companyId: json['company_id'] as String,
      totalMembers: json['total_members'] as int? ?? 0,
      role: $enumDecodeNullable(_$WorkspaceRoleEnumMap, json['role']) ??
          WorkspaceRole.member,
    );

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'company_id': instance.companyId,
      'total_members': instance.totalMembers,
      'role': _$WorkspaceRoleEnumMap[instance.role],
    };

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.moderator: 'moderator',
  WorkspaceRole.member: 'member',
};
