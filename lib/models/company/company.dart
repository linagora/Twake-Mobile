import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/company/company_role.dart';
import 'package:twake/utils/api_data_transformer.dart';

part 'company.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Company extends BaseModel {
  final String id;

  final String name;

  final String? logo;

  @JsonKey(defaultValue: 0)
  final int totalMembers;

  final CompanyRole role;

  String? selectedWorkspace;

  Company({
    required this.id,
    required this.name,
    required this.totalMembers,
    this.logo,
    this.selectedWorkspace,
    required this.role,
  });

  bool get canCreateWorkspace => role == CompanyRole.owner || role == CompanyRole.admin;

  bool get canUpdateChannel => role != CompanyRole.guest;

  bool get canGenerateMagicLink => role == CompanyRole.admin;

  bool get canShareMagicLink => role != CompanyRole.guest;

  factory Company.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: false,
    bool tranform: false,
  }) {
    // need to adjust the json structure before trying to map it to model
    if (tranform) {
      json = ApiDataTransformer.company(json: json);
    }

    return _$CompanyFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$CompanyToJson(this);
    return json;
  }
}
