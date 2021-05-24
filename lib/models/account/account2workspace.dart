import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';

part 'account2workspace.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Account2Workspace extends BaseModel {
  final String userId;
  final String workspaceId;

  const Account2Workspace({required this.userId, required this.workspaceId});

  factory Account2Workspace.fromJson({required Map<String, dynamic> json}) =>
      _$Account2WorkspaceFromJson(json);

  @override
  Map<String, dynamic> toJson({stringify: false}) {
    return _$Account2WorkspaceToJson(this);
  }
}
