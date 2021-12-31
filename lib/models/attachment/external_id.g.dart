// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExternalId _$ExternalIdFromJson(Map<String, dynamic> json) {
  return ExternalId(
    id: json['id'] as String,
    companyId: json['company_id'] as String,
  );
}

Map<String, dynamic> _$ExternalIdToJson(ExternalId instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
    };
