// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return Application(
    id: json['id'] as String,
    name: json['name'] as String ?? 'Unknown Bot',
  )
    ..iconUrl = json['icon_url'] as String
    ..description = json['description'] as String
    ..website = json['website'] as String;
}

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'description': instance.description,
      'website': instance.website,
    };
