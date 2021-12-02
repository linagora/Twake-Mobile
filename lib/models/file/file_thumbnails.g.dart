// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_thumbnails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileThumbnails _$FileThumbnailsFromJson(Map<String, dynamic> json) {
  return FileThumbnails(
    id: json['id'] as String,
    index: json['index'] as int,
    size: json['size'] as int,
    type: json['type'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
  );
}

Map<String, dynamic> _$FileThumbnailsToJson(FileThumbnails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'index': instance.index,
      'size': instance.size,
      'type': instance.type,
      'width': instance.width,
      'height': instance.height,
    };
