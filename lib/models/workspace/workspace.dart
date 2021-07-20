import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/workspace/workspace_role.dart';
import 'package:twake/utils/api_data_transformer.dart';

part 'workspace.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Workspace extends BaseModel {
  final String id;

  String name;

  String? logo;

  final String companyId;

  @JsonKey(defaultValue: 0)
  int totalMembers;

  final WorkspaceRole role;

  Workspace({
    required this.id,
    required this.name,
    this.logo,
    required this.companyId,
    required this.totalMembers,
    required this.role,
  });

  factory Workspace.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: false,
    bool transform: false,
  }) {
    // need to adjust the json structure before trying to map it to model
    if (transform) {
      json = ApiDataTransformer.workspace(json: json);
    }
    return _$WorkspaceFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$WorkspaceToJson(this);
    return json;
  }
}
