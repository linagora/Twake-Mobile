// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_direct_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddDirectRepository _$AddDirectRepositoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['company_id', 'member', 'workspace_id']);
  return AddDirectRepository()
    ..companyId = json['company_id'] as String
    ..member = json['member'] as String
    ..workspaceId = json['workspace_id'] as String;
}

Map<String, dynamic> _$AddDirectRepositoryToJson(
        AddDirectRepository instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'member': instance.member,
      'workspace_id': instance.workspaceId,
    };
