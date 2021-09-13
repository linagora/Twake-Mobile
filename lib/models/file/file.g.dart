// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

File _$FileFromJson(Map<String, dynamic> json) {
  return File(
    id: json['id'] as String,
    name: json['name'] as String,
    companyId: json['company_id'] as String,
    size: json['size'] as int,
    preview: json['preview'] as String?,
  );
}

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'company_id': instance.companyId,
      'preview': instance.preview,
      'size': instance.size,
    };
