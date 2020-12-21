// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name', 'company_id']);
  return Workspace(
    id: json['id'] as String,
    companyId: json['company_id'] as String,
    color: json['color'] as String,
    userLastAccess: json['user_last_access'] as int,
  )
    ..name = json['name'] as String
    ..logo = json['logo'] as String
    ..totalMembers = json['total_members'] as int
    ..isSelected = json['isSelected'] as bool ?? false;
}

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'company_id': instance.companyId,
      'color': instance.color,
      'logo': instance.logo,
      'user_last_access': instance.userLastAccess,
      'total_members': instance.totalMembers,
      'isSelected': instance.isSelected,
    };
