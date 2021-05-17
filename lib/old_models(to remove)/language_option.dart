import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'language_option.g.dart';

@JsonSerializable()
class LanguageOption {
  LanguageOption({
    @required this.value,
    @required this.title,
  });

  final String value;
  final String title;

  factory LanguageOption.fromJson(Map<String, dynamic> json) =>
      _$LanguageOptionFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageOptionToJson(this);
}
