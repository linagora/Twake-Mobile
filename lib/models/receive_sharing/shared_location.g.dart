// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedLocation _$SharedLocationFromJson(Map<String, dynamic> json) =>
    SharedLocation(
      id: json['id'] as int?,
      companyId: json['company_id'] as String,
      workspaceId: json['workspace_id'] as String,
      channelId: json['channel_id'] as String,
    );

Map<String, dynamic> _$SharedLocationToJson(SharedLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'workspace_id': instance.workspaceId,
      'channel_id': instance.channelId,
    };
