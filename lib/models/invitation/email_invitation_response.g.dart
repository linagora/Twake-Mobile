// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_invitation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailInvitationResponse _$EmailInvitationResponseFromJson(
        Map<String, dynamic> json) =>
    EmailInvitationResponse(
      json['email'] as String,
      json['message'] as String?,
      $enumDecode(_$EmailInvitationResponseStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$EmailInvitationResponseToJson(
        EmailInvitationResponse instance) =>
    <String, dynamic>{
      'email': instance.email,
      'message': instance.message,
      'status': _$EmailInvitationResponseStatusEnumMap[instance.status],
    };

const _$EmailInvitationResponseStatusEnumMap = {
  EmailInvitationResponseStatus.ok: 'ok',
  EmailInvitationResponseStatus.error: 'error',
};
