import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';

part 'add_workspace_repository.g.dart';

enum FlowStage {
  info,
  collaborators,
}

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

  AddWorkspaceRepository({
    this.name,
    this.companyId,
    this.workspaceId,
    this.members,
  });

  factory AddWorkspaceRepository.fromJson(Map<String, dynamic> json) =>
      _$AddWorkspaceRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$AddWorkspaceRepositoryToJson(this);

  Future<void> clear() async {
    companyId = '';
    workspaceId = '';
    name = '';
    members = [];
  }

  Future<String> create() async {
    this.companyId = ProfileBloc.selectedCompany;
    final body = this.toJson();

    _logger.d('Workspace creation request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.post(Endpoint.workspaces, body: body);
    } catch (error) {
      _logger.e('Error while trying to create a workspace:\n${error.message}');
      return '';
    }
    _logger.d('RESPONSE AFTER WORKSPACE CREATION: $resp');
    // {id: e587ca3c-66a1-11eb-b421-0242ac120004, private: false, logo: , wallpaper: , color: #7E7A6D,
    // group: {id: 0e9337d6-54eb-11eb-9e45-0242ac120004, unique_name: 9922ca9a-11e3-4873-bb61-6de5461b0d46,
    // name: Dave Company, plan: {name: Free plan, limits: []}, logo: , isBlocked: false, total_members: 0},
    // name: w1, total_members: 1, total_guests: 0, total_pending: 0, unique_name: w1-387091468a, is_archived: false, is_new: true}
    String workspaceId = resp['id'];
    return workspaceId;
  }

  Future<bool> updateMembers({
    @required List<String> members,
    @required String workspaceId,
  }) async {
    String companyId = ProfileBloc.selectedCompany;

    final body = <String, dynamic>{
      'company_id': companyId,
      'workspace_id': workspaceId,
      'members': members,
    };
    _logger.d('Member update request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.post(Endpoint.workspaceMembers, body: body);
    } catch (error) {
      _logger.e('Error while trying to update members of a workspace: $error');
      return false;
    }
    _logger.d('RESPONSE AFTER MEMBERS UPDATE: $resp');
    return true;
  }
}
