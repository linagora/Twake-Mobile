// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Authentication _$AuthenticationFromJson(Map<String, dynamic> json) {
  return Authentication(
    token: json['token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiration: json['expiration'] as int,
    refreshExpiration: json['refresh_expiration'] as int,
  );
}

Map<String, dynamic> _$AuthenticationToJson(Authentication instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refresh_token': instance.refreshToken,
      'expiration': instance.expiration,
      'refresh_expiration': instance.refreshExpiration,
    };
