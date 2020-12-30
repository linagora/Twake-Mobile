// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name']);
  return Company(
    id: json['id'] as String,
    name: json['name'] as String,
    logo: json['logo'] as String,
    totalMembers: json['total_members'] as int ?? 0,
  )..isSelected = intToBool(json['is_selected'] as int);
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'total_members': instance.totalMembers,
      'is_selected': boolToInt(instance.isSelected),
    };
