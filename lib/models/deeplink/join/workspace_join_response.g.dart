// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_join_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceJoinResponse _$WorkspaceJoinResponseFromJson(
        Map<String, dynamic> json) =>
    WorkspaceJoinResponse(
      WorkspaceJoinResponseCompany.fromJson(
          json['company'] as Map<String, dynamic>),
      WorkspaceJoinResponseWorkspace.fromJson(
          json['workspace'] as Map<String, dynamic>),
      json['auth_url'] as String?,
    );

Map<String, dynamic> _$WorkspaceJoinResponseToJson(
        WorkspaceJoinResponse instance) =>
    <String, dynamic>{
      'company': instance.company.toJson(),
      'workspace': instance.workspace.toJson(),
      'auth_url': instance.authUrl,
    };
