// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailInvitation _$EmailInvitationFromJson(Map<String, dynamic> json) =>
    EmailInvitation(
      email: json['email'] as String,
      companyRole: $enumDecode(_$CompanyRoleEnumMap, json['company_role']),
      workspaceRole: $enumDecode(_$WorkspaceRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$EmailInvitationToJson(EmailInvitation instance) =>
    <String, dynamic>{
      'email': instance.email,
      'company_role': _$CompanyRoleEnumMap[instance.companyRole],
      'role': _$WorkspaceRoleEnumMap[instance.workspaceRole],
    };

const _$CompanyRoleEnumMap = {
  CompanyRole.owner: 'owner',
  CompanyRole.admin: 'admin',
  CompanyRole.member: 'member',
  CompanyRole.guest: 'guest',
};

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.moderator: 'moderator',
  WorkspaceRole.member: 'member',
};
