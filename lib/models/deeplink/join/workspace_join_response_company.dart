import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_join_response_company.g.dart';

@JsonSerializable()
class WorkspaceJoinResponseCompany extends BaseModel with EquatableMixin {

  final String name;
  final String? id;

  const WorkspaceJoinResponseCompany(this.name, this.id);

  factory WorkspaceJoinResponseCompany.fromJson(Map<String, dynamic> json) => _$WorkspaceJoinResponseCompanyFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$WorkspaceJoinResponseCompanyToJson(this);

  @override
  List<Object?> get props => [name, id];

}