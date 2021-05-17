// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountField _$AccountFieldFromJson(Map<String, dynamic> json) {
  return AccountField(
    isReadonly: json['readonly'] as bool ?? false,
    value: json['value'] as String ?? '',
  );
}

Map<String, dynamic> _$AccountFieldToJson(AccountField instance) =>
    <String, dynamic>{
      'readonly': instance.isReadonly,
      'value': instance.value,
    };
