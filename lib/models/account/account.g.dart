// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    id: json['id'] as String,
    email: json['email'] as String,
    firstname: json['firstname'] as String?,
    lastname: json['lastname'] as String?,
    username: json['username'] as String,
    thumbnail: json['thumbnail'] as String?,
    consoleId: json['console_id'] as String?,
    status: json['status'] as String?,
    statusIcon: json['status_icon'] as String?,
    language: json['language'] as String?,
    lastActivity: json['last_activity'] as int,
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'username': instance.username,
      'thumbnail': instance.thumbnail,
      'console_id': instance.consoleId,
      'status_icon': instance.statusIcon,
      'status': instance.status,
      'language': instance.language,
      'last_activity': instance.lastActivity,
    };
