// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountField _$AccountFieldFromJson(Map<String, dynamic> json) {
  return AccountField(
    isReadonly: json['isReadonly'] as bool,
    value: json['value'] as String,
  );
}

Map<String, dynamic> _$AccountFieldToJson(AccountField instance) =>
    <String, dynamic>{
      'isReadonly': instance.isReadonly,
      'value': instance.value,
    };
