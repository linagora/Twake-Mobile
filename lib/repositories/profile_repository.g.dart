// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileRepository _$ProfileRepositoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['userId', 'username']);
  return ProfileRepository(
    userId: json['userId'] as String,
    username: json['username'] as String,
  )
    ..firstName = json['firstname'] as String
    ..lastName = json['lastname'] as String
    ..thumbnail = json['thumbnail'] as String;
}

Map<String, dynamic> _$ProfileRepositoryToJson(ProfileRepository instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'thumbnail': instance.thumbnail,
    };
