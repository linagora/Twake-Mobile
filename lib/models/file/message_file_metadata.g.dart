// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_file_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageFileMetadata _$MessageFileMetadataFromJson(Map<String, dynamic> json) =>
    MessageFileMetadata(
      name: json['name'] as String,
      mime: json['mime'] as String,
      externalId: json['external_id'] as String,
      thumbnailsStatus:
          $enumDecode(_$ThumbnailStatusEnumMap, json['thumbnails_status']),
      size: json['size'] as int,
      thumbnails: (json['thumbnails'] as List<dynamic>)
          .map((e) => FileThumbnails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessageFileMetadataToJson(
        MessageFileMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mime': instance.mime,
      'external_id': instance.externalId,
      'thumbnails_status': _$ThumbnailStatusEnumMap[instance.thumbnailsStatus],
      'size': instance.size,
      'thumbnails': instance.thumbnails,
    };

const _$ThumbnailStatusEnumMap = {
  ThumbnailStatus.done: 'done',
  ThumbnailStatus.waiting: 'waiting',
};
