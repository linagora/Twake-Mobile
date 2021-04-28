// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountRepository _$AccountRepositoryFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['username', 'firstname', 'lastname']);
  return AccountRepository(
    userName: json['username'] == null
        ? null
        : AccountField.fromJson(json['username'] as Map<String, dynamic>),
    firstName: json['firstname'] == null
        ? null
        : AccountField.fromJson(json['firstname'] as Map<String, dynamic>),
    lastName: json['lastname'] == null
        ? null
        : AccountField.fromJson(json['lastname'] as Map<String, dynamic>),
    language: json['language'] == null
        ? null
        : LanguageField.fromJson(json['language'] as Map<String, dynamic>),
    picture: json['picture'] == null
        ? null
        : AccountField.fromJson(json['picture'] as Map<String, dynamic>),
    password: json['password'] == null
        ? null
        : PasswordField.fromJson(json['password'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AccountRepositoryToJson(AccountRepository instance) =>
    <String, dynamic>{
      'username': instance.userName?.toJson(),
      'firstname': instance.firstName?.toJson(),
      'lastname': instance.lastName?.toJson(),
      'language': instance.language?.toJson(),
      'picture': instance.picture?.toJson(),
      'password': instance.password?.toJson(),
    };
