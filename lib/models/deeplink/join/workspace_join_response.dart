import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/deeplink/join/workspace_join_response_company.dart';
import 'package:twake/models/deeplink/join/workspace_join_response_workspace.dart';
part 'workspace_join_response.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkspaceJoinResponse extends BaseModel with EquatableMixin {

  final WorkspaceJoinResponseCompany company;
  final WorkspaceJoinResponseWorkspace workspace;

  @JsonKey(name: 'auth_url')
  final String? authUrl;

  WorkspaceJoinResponse(this.company, this.workspace, this.authUrl);

  factory WorkspaceJoinResponse.fromJson(Map<String, dynamic> json) => _$WorkspaceJoinResponseFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$WorkspaceJoinResponseToJson(this);

  @override
  List<Object?> get props => [company, workspace, authUrl];

}