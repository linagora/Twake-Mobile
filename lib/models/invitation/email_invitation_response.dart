import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/invitation/email_invitation_response_status.dart';

part 'email_invitation_response.g.dart';

@JsonSerializable()
class EmailInvitationResponse extends BaseModel with EquatableMixin {

  final String email;
  final String? message;
  final EmailInvitationResponseStatus status;

  EmailInvitationResponse(this.email, this.message, this.status);

  factory EmailInvitationResponse.fromJson(Map<String, dynamic> json) => _$EmailInvitationResponseFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$EmailInvitationResponseToJson(this);

  @override
  List<Object?> get props => [email, message, status];

}