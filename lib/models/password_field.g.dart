// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordField _$PasswordFieldFromJson(Map<String, dynamic> json) {
  return PasswordField(
    isReadonly: json['isReadonly'] as bool,
    value: json['value'] == null
        ? null
        : PasswordValues.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PasswordFieldToJson(PasswordField instance) =>
    <String, dynamic>{
      'isReadonly': instance.isReadonly,
      'value': instance.value,
    };
