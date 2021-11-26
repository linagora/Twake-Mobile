import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_join_response_workspace.g.dart';

@JsonSerializable()
class WorkspaceJoinResponseWorkspace extends BaseModel with EquatableMixin {

  final String name;
  final String? id;

  const WorkspaceJoinResponseWorkspace(this.name, this.id);

  factory WorkspaceJoinResponseWorkspace.fromJson(Map<String, dynamic> json) => _$WorkspaceJoinResponseWorkspaceFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$WorkspaceJoinResponseWorkspaceToJson(this);

  @override
  List<Object?> get props => [name, id];

}