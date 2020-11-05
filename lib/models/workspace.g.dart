// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name']);
  return Workspace(
    id: json['id'] as String,
    name: json['name'] as String,
    logo: json['logo'] as String,
  );
}

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
    };
