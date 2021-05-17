import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/language_option.dart';

part 'language_field.g.dart';

@JsonSerializable()
class LanguageField {
  LanguageField({
    @required this.isReadonly,
    @required this.value,
    @required this.options,
  });

  @JsonKey(name: 'readonly', defaultValue: false)
  final bool isReadonly;
  @JsonKey(defaultValue: [])
  final List<LanguageOption> options;
  @JsonKey(defaultValue: '')
  String value;

  factory LanguageField.fromJson(Map<String, dynamic> json) =>
      _$LanguageFieldFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageFieldToJson(this);
}
