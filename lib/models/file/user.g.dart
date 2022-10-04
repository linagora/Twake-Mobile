// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      email: json['email'] as String,
      userName: json['user_name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      lastSeen: json['last_seen'] as int?,
      isConnected: json['is_connected'] as bool?,
      fullName: json['full_name'] as String,
      verified: json['is_verified'] as bool,
      deleted: json['deleted'] as bool,
      picture: json['picture'] as String?,
      providerId: json['provider_id'] as String?,
      status: json['status'] as String?,
      lastActivity: json['last_activity'] as int,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'user_name': instance.userName,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'full_name': instance.fullName,
      'picture': instance.picture,
      'provider_id': instance.providerId,
      'status': instance.status,
      'last_activity': instance.lastActivity,
      'last_seen': instance.lastSeen,
      'is_connected': instance.isConnected,
      'is_verified': instance.verified,
      'deleted': instance.deleted,
    };
