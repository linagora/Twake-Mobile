// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRepository _$AuthRepositoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'token',
    'refresh_token',
    'expiration',
    'refresh_expiration'
  ]);
  return AuthRepository()
    ..accessToken = json['token'] as String
    ..refreshToken = json['refresh_token'] as String
    ..accessTokenExpiration = json['expiration'] == null
        ? null
        : DateTime.parse(json['expiration'] as String)
    ..refreshTokenExpiration = json['refresh_expiration'] == null
        ? null
        : DateTime.parse(json['refresh_expiration'] as String);
}

Map<String, dynamic> _$AuthRepositoryToJson(AuthRepository instance) =>
    <String, dynamic>{
      'token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expiration': instance.accessTokenExpiration?.toIso8601String(),
      'refresh_expiration': instance.refreshTokenExpiration?.toIso8601String(),
    };
