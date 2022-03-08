// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    username: json['username'] as String,
    verified: json['is_verified'] as int,
    deleted: json['deleted'] as int,
    picture: json['picture'] as String?,
    providerId: json['provider_id'] as String?,
    status: json['status'] as String?,
    lastActivity: json['last_activity'] as int,
    recentWorkspaceId: json['workspace_id'] as String?,
    recentCompanyId: json['company_id'] as String?,
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'username': instance.username,
      'picture': instance.picture,
      'provider_id': instance.providerId,
      'status': instance.status,
      'last_activity': instance.lastActivity,
      'workspace_id': instance.recentWorkspaceId,
      'company_id': instance.recentCompanyId,
      'is_verified': instance.verified,
      'deleted': instance.deleted,
    };
