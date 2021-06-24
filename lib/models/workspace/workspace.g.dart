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
    userLastAccess: json['user_last_access'] as int,
    permissions:
        (json['permissions'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'company_id': instance.companyId,
      'total_members': instance.totalMembers,
      'user_last_access': instance.userLastAccess,
      'permissions': instance.permissions,
    };
