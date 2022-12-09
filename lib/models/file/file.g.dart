// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

File _$FileFromJson(Map<String, dynamic> json) => File(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      metadata: FileMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      thumbnails: (json['thumbnails'] as List<dynamic>)
          .map((e) => FileThumbnails.fromJson(e as Map<String, dynamic>))
          .toList(),
      uploadData:
          FileUploadData.fromJson(json['upload_data'] as Map<String, dynamic>),
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'user_id': instance.userId,
      'metadata': instance.metadata,
      'thumbnails': instance.thumbnails,
      'upload_data': instance.uploadData,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
