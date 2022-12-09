// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileUploadData _$FileUploadDataFromJson(Map<String, dynamic> json) =>
    FileUploadData(
      size: json['size'] as int,
      chunks: json['chunks'] as int,
    );

Map<String, dynamic> _$FileUploadDataToJson(FileUploadData instance) =>
    <String, dynamic>{
      'size': instance.size,
      'chunks': instance.chunks,
    };
