// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return Company(
    id: json['id'] as String,
    name: json['name'] as String,
    totalMembers: json['total_members'] as int,
    permissions:
        (json['permissions'] as List<dynamic>).map((e) => e as String).toList(),
    logo: json['logo'] as String?,
    selectedWorkspace: json['selected_workspace'] as String?,
  );
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'total_members': instance.totalMembers,
      'selected_workspace': instance.selectedWorkspace,
      'permissions': instance.permissions,
    };
