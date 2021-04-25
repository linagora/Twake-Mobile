import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'password_values.g.dart';

@JsonSerializable()
class PasswordValues {
  PasswordValues({
    @required this.oldPass,
    @required this.newPass,
  });

  final String oldPass;
  final String newPass;

  factory PasswordValues.fromJson(Map<String, dynamic> json) =>
      _$PasswordValuesFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordValuesToJson(this);
}
