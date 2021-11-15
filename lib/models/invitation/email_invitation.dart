import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/company/company_role.dart';
import 'package:twake/models/workspace/workspace_role.dart';

part 'email_invitation.g.dart';

@JsonSerializable()
class EmailInvitation extends BaseModel with EquatableMixin {

  final String email;

  @JsonKey(name: 'company_role')
  final CompanyRole companyRole;

  @JsonKey(name: 'role')
  final WorkspaceRole workspaceRole;

  const EmailInvitation({required this.email, required this.companyRole, required this.workspaceRole});

  factory EmailInvitation.fromJson(Map<String, dynamic> json) => _$EmailInvitationFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$EmailInvitationToJson(this);

  @override
  List<Object> get props => [email, companyRole, workspaceRole];

}