// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'globals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Globals _$GlobalsFromJson(Map<String, dynamic> json) {
  return Globals(
    host: json['host'] as String,
    channelsType:
        _$enumDecodeNullable(_$ChannelsTypeEnumMap, json['channels_type']) ??
            ChannelsType.commons,
    token: json['token'] as String?,
    fcmToken: json['fcm_token'] as String,
    userId: json['user_id'] as String?,
    companyId: json['company_id'] as String?,
    workspaceId: json['workspace_id'] as String?,
    channelId: json['channel_id'] as String?,
    threadId: json['thread_id'] as String?,
    helpUrl: json['help_url'] as String?,
  )
    ..clientId = json['client_id'] as String?
    ..oidcAuthority = json['oidc_authority'] as String?;
}

Map<String, dynamic> _$GlobalsToJson(Globals instance) => <String, dynamic>{
      'host': instance.host,
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
      'thread_id': instance.threadId,
      'channels_type': _$ChannelsTypeEnumMap[instance.channelsType],
      'token': instance.token,
      'fcm_token': instance.fcmToken,
      'user_id': instance.userId,
      'client_id': instance.clientId,
      'oidc_authority': instance.oidcAuthority,
      'help_url': instance.helpUrl,
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$ChannelsTypeEnumMap = {
  ChannelsType.directs: 'directs',
  ChannelsType.commons: 'commons',
};
