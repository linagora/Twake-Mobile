// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'username']);
  return User(
    id: json['id'] as String,
    username: json['username'] as String,
    firstName: json['firstname'] as String,
    lastName: json['lastname'] as String,
    thumbnail: json['thumbnail'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'thumbnail': instance.thumbnail,
    };
