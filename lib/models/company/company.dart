import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/company/company_role.dart';

part 'company.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Company extends BaseModel {
  final String id;

  final String name;

  final String? logo;

  @JsonKey(defaultValue: 0)
  final int totalMembers;

  CompanyRole role;

  String? selectedWorkspace;

  Company({
    required this.id,
    required this.name,
    required this.totalMembers,
    this.logo,
    this.selectedWorkspace,
    required this.role,
  });

  factory Company.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: true,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back, composite fields are absent for company model
    return _$CompanyFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$CompanyToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields, composite fields are absent for company model
    return json;
  }
}
