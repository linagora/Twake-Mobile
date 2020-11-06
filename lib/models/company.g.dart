// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name', 'workspaces']);
  return Company(
    id: json['id'] as String,
    name: json['name'] as String,
    workspaces: (json['workspaces'] as List)
        ?.map((e) =>
            e == null ? null : Workspace.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    logo: json['logo'] as String,
  );
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'workspaces': instance.workspaces?.map((e) => e?.toJson())?.toList(),
    };
