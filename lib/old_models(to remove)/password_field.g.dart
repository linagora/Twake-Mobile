// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordField _$PasswordFieldFromJson(Map<String, dynamic> json) {
  return PasswordField(
    isReadonly: json['readonly'] as bool ?? false,
    value: json['value'] == null
        ? null
        : PasswordValues.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PasswordFieldToJson(PasswordField instance) =>
    <String, dynamic>{
      'readonly': instance.isReadonly,
      'value': instance.value,
    };
