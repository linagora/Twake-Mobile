// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_values.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordValues _$PasswordValuesFromJson(Map<String, dynamic> json) {
  return PasswordValues(
    oldPassword: json['old'] as String ?? '',
    newPassword: json['new'] as String ?? '',
  );
}

Map<String, dynamic> _$PasswordValuesToJson(PasswordValues instance) =>
    <String, dynamic>{
      'old': instance.oldPassword,
      'new': instance.newPassword,
    };
