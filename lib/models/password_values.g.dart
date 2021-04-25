// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_values.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordValues _$PasswordValuesFromJson(Map<String, dynamic> json) {
  return PasswordValues(
    oldPass: json['oldPass'] as String,
    newPass: json['newPass'] as String,
  );
}

Map<String, dynamic> _$PasswordValuesToJson(PasswordValues instance) =>
    <String, dynamic>{
      'oldPass': instance.oldPass,
      'newPass': instance.newPass,
    };
