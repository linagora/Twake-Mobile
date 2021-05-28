// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) {
  return Channel(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String?,
    description: json['description'] as String?,
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    lastMessage: json['last_message'] == null
        ? null
        : MessageSummary.fromJson(json['last_message'] as Map<String, dynamic>),
    members:
        (json['members'] as List<dynamic>).map((e) => e as String).toList(),
    visibility: _$enumDecode(_$ChannelVisibilityEnumMap, json['visibility']),
    lastActivity: json['last_activity'] as int,
    userLastAccess: json['user_last_access'] as int? ?? 0,
    draft: json['draft'] as String?,
    permissions:
        (json['permissions'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'members': instance.members,
      'visibility': _$ChannelVisibilityEnumMap[instance.visibility],
      'last_activity': instance.lastActivity,
      'last_message': instance.lastMessage?.toJson(),
      'user_last_access': instance.userLastAccess,
      'draft': instance.draft,
      'permissions': instance.permissions,
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

const _$ChannelVisibilityEnumMap = {
  ChannelVisibility.Public: 'public',
  ChannelVisibility.Private: 'private',
  ChannelVisibility.Direct: 'direct',
};
