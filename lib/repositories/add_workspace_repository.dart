import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';

part 'add_workspace_repository.g.dart';

@JsonSerializable(explicitToJson: true)
class AddWorkspaceRepository {
  @JsonKey(required: true, name: 'company_id')
  String companyId;
  @JsonKey(required: true, name: 'workspace_id')
  String workspaceId;
  @JsonKey(required: true)
  String name;
  @JsonKey(required: false)
  List<String> members;

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();

  AddWorkspaceRepository(
    this.companyId,
    this.name, {
    this.workspaceId,
    this.members,
  });

  factory AddWorkspaceRepository.fromJson(Map<String, dynamic> json) =>
      _$AddWorkspaceRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$AddWorkspaceRepositoryToJson(this);
}
