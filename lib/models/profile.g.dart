// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['userId', 'username', 'companies']);
  return Profile(
    userId: json['userId'] as String,
    username: json['username'] as String,
    companies: (json['companies'] as List)
        ?.map((e) =>
            e == null ? null : Company.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    firstName: json['firstname'] as String,
    lastName: json['lastname'] as String,
    thumbnail: json['thumbnail'] as String,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'thumbnail': instance.thumbnail,
      'companies': instance.companies?.map((e) => e?.toJson())?.toList(),
    };
