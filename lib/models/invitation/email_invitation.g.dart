// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailInvitation _$EmailInvitationFromJson(Map<String, dynamic> json) {
  return EmailInvitation(
    email: json['email'] as String,
    companyRole: _$enumDecode(_$CompanyRoleEnumMap, json['company_role']),
    workspaceRole: _$enumDecode(_$WorkspaceRoleEnumMap, json['role']),
  );
}

Map<String, dynamic> _$EmailInvitationToJson(EmailInvitation instance) =>
    <String, dynamic>{
      'email': instance.email,
      'company_role': _$CompanyRoleEnumMap[instance.companyRole],
      'role': _$WorkspaceRoleEnumMap[instance.workspaceRole],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$CompanyRoleEnumMap = {
  CompanyRole.owner: 'owner',
  CompanyRole.admin: 'admin',
  CompanyRole.member: 'member',
  CompanyRole.guest: 'guest',
};

const _$WorkspaceRoleEnumMap = {
  WorkspaceRole.admin: 'admin',
  WorkspaceRole.moderator: 'moderator',
  WorkspaceRole.member: 'member',
};
