import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'password_values.g.dart';

@JsonSerializable()
class PasswordValues {
  const PasswordValues({
    @required this.oldPassword,
    @required this.newPassword,
  });

  @JsonKey(name: 'old', defaultValue: '')
  final String oldPassword;
  @JsonKey(name: 'new', defaultValue: '')
  final String newPassword;

  factory PasswordValues.fromJson(Map<String, dynamic> json) =>
      _$PasswordValuesFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordValuesToJson(this);
}
