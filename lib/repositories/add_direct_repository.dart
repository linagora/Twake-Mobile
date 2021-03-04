import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';

part 'add_direct_repository.g.dart';

@JsonSerializable(explicitToJson: true)
class AddDirectRepository {
  @JsonKey(required: true, name: 'company_id')
  String companyId;
  @JsonKey(required: true)
  String member;
  @JsonKey(required: true, name: 'workspace_id')
  String workspaceId = 'direct';

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();

  AddDirectRepository({
    this.companyId,
    this.workspaceId,
    this.member,
  });

  factory AddDirectRepository.fromJson(Map<String, dynamic> json) =>
      _$AddDirectRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$AddDirectRepositoryToJson(this);

  Future<void> clear() async {
    companyId = '';
    member = '';
  }

  Future<String> create() async {
    this.companyId = ProfileBloc.selectedCompany;
    this.workspaceId = 'direct';

    final body = this.toJson();
    _logger.d('Direct creation request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.post(Endpoint.directs, body: body);
    } catch (error) {
      _logger.e('Error while trying to create a direct:\n${error.message}');
      return '';
    }
    _logger.d('RESPONSE AFTER DIRECT CREATION: $resp');
    String directId = resp['id'];
    return directId;
  }
}
