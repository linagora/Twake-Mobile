import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/utils/json.dart' as jsn;

part 'workspace.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Workspace extends BaseModel {
  static const COMPOSITE_FIELDS = ['permissions'];

  final String id;

  String name;

  String? logo;

  final String companyId;

  @JsonKey(defaultValue: 0)
  int totalMembers;

  @JsonKey(defaultValue: 0)
  int userLastAccess;

  List<String> permissions;

  Workspace({
    required this.id,
    required this.name,
    this.logo,
    required this.companyId,
    required this.totalMembers,
    required this.userLastAccess,
    required this.permissions,
  });

  factory Workspace.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: true,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: COMPOSITE_FIELDS);
    }
    return _$WorkspaceFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$WorkspaceToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: COMPOSITE_FIELDS);
    }
    return json;
  }
}
