// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_invitation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailInvitationResponse _$EmailInvitationResponseFromJson(
    Map<String, dynamic> json) {
  return EmailInvitationResponse(
    json['email'] as String,
    json['message'] as String?,
    _$enumDecode(_$EmailInvitationResponseStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$EmailInvitationResponseToJson(
        EmailInvitationResponse instance) =>
    <String, dynamic>{
      'email': instance.email,
      'message': instance.message,
      'status': _$EmailInvitationResponseStatusEnumMap[instance.status],
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

const _$EmailInvitationResponseStatusEnumMap = {
  EmailInvitationResponseStatus.ok: 'ok',
  EmailInvitationResponseStatus.error: 'error',
};
