// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companies_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompaniesRepository _$CompaniesRepositoryFromJson(Map<String, dynamic> json) {
  return CompaniesRepository(
    (json['companies'] as List)
        ?.map((e) =>
            e == null ? null : Company.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CompaniesRepositoryToJson(
        CompaniesRepository instance) =>
    <String, dynamic>{
      'companies': instance.companies?.map((e) => e?.toJson())?.toList(),
    };
