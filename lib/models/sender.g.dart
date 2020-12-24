// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sender _$SenderFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['userId']);
  return Sender(
    username: json['username'] as String ?? 'BOT',
    thumbnail: json['thumbnail'] as String,
    userId: json['userId'] as String,
    firstName: json['firstname'] as String,
    lastName: json['lastname'] as String,
  );
}

Map<String, dynamic> _$SenderToJson(Sender instance) => <String, dynamic>{
      'username': instance.username,
      'thumbnail': instance.thumbnail,
      'userId': instance.userId,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
    };
