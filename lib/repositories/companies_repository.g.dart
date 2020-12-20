// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companies_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name', 'isSelected']);
  return Company(
    id: json['id'] as String,
    name: json['name'] as String,
    logo: json['logo'] as String,
  )..isSelected = json['isSelected'] as bool;
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'isSelected': instance.isSelected,
    };
