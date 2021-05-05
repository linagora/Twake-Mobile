// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageField _$LanguageFieldFromJson(Map<String, dynamic> json) {
  return LanguageField(
    isReadonly: json['isReadonly'] as bool,
    value: json['value'] as String,
    options: (json['options'] as List)
        ?.map((e) => e == null
            ? null
            : LanguageOption.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$LanguageFieldToJson(LanguageField instance) =>
    <String, dynamic>{
      'isReadonly': instance.isReadonly,
      'options': instance.options,
      'value': instance.value,
    };
