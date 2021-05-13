import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_field.g.dart';

@JsonSerializable()
class AccountField {
  AccountField({@required this.isReadonly, @required this.value});

  @JsonKey(name: 'readonly', defaultValue: false)
  bool isReadonly;
  @JsonKey(defaultValue: '')
  String value;

  factory AccountField.fromJson(Map<String, dynamic> json) =>
      _$AccountFieldFromJson(json);

  Map<String, dynamic> toJson() => _$AccountFieldToJson(this);
}
