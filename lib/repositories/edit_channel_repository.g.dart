// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_channel_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditChannelRepository _$EditChannelRepositoryFromJson(
    Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['company_id', 'workspace_id', 'channel_id', 'name']);
  return EditChannelRepository(
    channelId: json['channel_id'] as String,
    name: json['name'] as String,
    companyId: json['company_id'] as String,
    workspaceId: json['workspace_id'] as String,
    icon: json['icon'] as String,
    description: json['description'] as String,
    def: json['def'] as bool,
  );
}

Map<String, dynamic> _$EditChannelRepositoryToJson(
        EditChannelRepository instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'def': instance.def,
    };
