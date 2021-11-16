import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace_invite_token.g.dart';

@JsonSerializable()
class WorkspaceInviteToken extends BaseModel with EquatableMixin {

  final String token;

  const WorkspaceInviteToken(this.token);

  factory WorkspaceInviteToken.fromJson(Map<String, dynamic> json) => _$WorkspaceInviteTokenFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$WorkspaceInviteTokenToJson(this);

  @override
  List<Object> get props => [token];

}