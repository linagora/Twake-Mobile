import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_field.g.dart';

@JsonSerializable()
class AccountField {
  AccountField({@required this.isReadonly, @required this.value});

  bool isReadonly;
  String value;

  factory AccountField.fromJson(Map<String, dynamic> json) =>
      _$AccountFieldFromJson(json);

  Map<String, dynamic> toJson() => _$AccountFieldToJson(this);
}
