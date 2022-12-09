// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileMetadata _$FileMetadataFromJson(Map<String, dynamic> json) => FileMetadata(
      name: json['name'] as String,
      mime: json['mime'] as String,
      thumbnailsStatus:
          $enumDecode(_$ThumbnailStatusEnumMap, json['thumbnails_status']),
    );

Map<String, dynamic> _$FileMetadataToJson(FileMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mime': instance.mime,
      'thumbnails_status': _$ThumbnailStatusEnumMap[instance.thumbnailsStatus],
    };

const _$ThumbnailStatusEnumMap = {
  ThumbnailStatus.done: 'done',
  ThumbnailStatus.waiting: 'waiting',
};
