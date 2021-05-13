import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/password_values.dart';

part 'password_field.g.dart';

@JsonSerializable()
class PasswordField {
  const PasswordField({
    @required this.isReadonly,
    @required this.value,
  });

  @JsonKey(name: 'readonly', defaultValue: false)
  final bool isReadonly;
  final PasswordValues value;

  factory PasswordField.fromJson(Map<String, dynamic> json) =>
      _$PasswordFieldFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordFieldToJson(this);
}
