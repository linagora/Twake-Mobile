// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentMetadata _$AttachmentMetadataFromJson(Map<String, dynamic> json) =>
    AttachmentMetadata(
      source: $enumDecode(_$SourceEnumMap, json['source']),
      externalId:
          ExternalId.fromJson(json['external_id'] as Map<String, dynamic>),
      name: json['name'] as String,
      mime: json['mime'] as String,
      size: json['size'] as int,
      thumbnails: (json['thumbnails'] as List<dynamic>)
          .map((e) => FileThumbnails.fromJson(e as Map<String, dynamic>))
          .toList(),
      thumbnailsStatus:
          $enumDecode(_$ThumbnailStatusEnumMap, json['thumbnails_status']),
    );

Map<String, dynamic> _$AttachmentMetadataToJson(AttachmentMetadata instance) =>
    <String, dynamic>{
      'source': _$SourceEnumMap[instance.source],
      'external_id': instance.externalId,
      'name': instance.name,
      'mime': instance.mime,
      'size': instance.size,
      'thumbnails': instance.thumbnails,
      'thumbnails_status': _$ThumbnailStatusEnumMap[instance.thumbnailsStatus],
    };

const _$SourceEnumMap = {
  Source.internal: 'internal',
  Source.drive: 'drive',
};

const _$ThumbnailStatusEnumMap = {
  ThumbnailStatus.done: 'done',
  ThumbnailStatus.waiting: 'waiting',
};
