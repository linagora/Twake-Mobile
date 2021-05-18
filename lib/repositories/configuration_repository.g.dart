// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigurationRepository _$ConfigurationRepositoryFromJson(
    Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['host']);
  return ConfigurationRepository(
    host: json['host'] as String?,
  );
}

Map<String, dynamic> _$ConfigurationRepositoryToJson(
        ConfigurationRepository instance) =>
    <String, dynamic>{
      'host': instance.host,
    };
