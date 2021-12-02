// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileMetadata _$FileMetadataFromJson(Map<String, dynamic> json) {
  return FileMetadata(
    name: json['name'] as String,
    mime: json['mime'] as String,
    thumbnailsStatus:
        _$enumDecode(_$ThumbnailStatusEnumMap, json['thumbnails_status']),
  );
}

Map<String, dynamic> _$FileMetadataToJson(FileMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mime': instance.mime,
      'thumbnails_status': _$ThumbnailStatusEnumMap[instance.thumbnailsStatus],
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

const _$ThumbnailStatusEnumMap = {
  ThumbnailStatus.done: 'done',
  ThumbnailStatus.waiting: 'waiting',
};
