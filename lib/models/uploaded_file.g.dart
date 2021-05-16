// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uploaded_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadedFile _$UploadedFileFromJson(Map<String, dynamic> json) {
  return UploadedFile(
    id: json['id'] as String,
    filename: json['name'] as String,
    preview: json['preview'] as String,
    download: json['download'] as String,
    file: json['file'] as String,
    size: json['size'] as int,
  );
}

Map<String, dynamic> _$UploadedFileToJson(UploadedFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.filename,
      'preview': instance.preview,
      'download': instance.download,
      'file': instance.file,
      'size': instance.size,
    };
