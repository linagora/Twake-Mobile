// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountRepository _$AccountRepositoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'username']);
  return AccountRepository(
    id: json['id'] as String,
    username: json['username'] as String,
  )
    ..firstName = json['firstname'] as String
    ..lastName = json['lastname'] as String
    ..thumbnail = json['thumbnail'] as String
    ..selectedCompanyId = json['selected_company_id'] as String
    ..selectedWorkspaceId = json['selected_workspace_id'] as String;
}

Map<String, dynamic> _$AccountRepositoryToJson(AccountRepository instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'thumbnail': instance.thumbnail,
      'selected_company_id': instance.selectedCompanyId,
      'selected_workspace_id': instance.selectedWorkspaceId,
    };
