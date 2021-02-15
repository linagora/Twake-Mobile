import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';

part 'edit_channel_repository.g.dart';

enum EditFlowStage {
  manage,
  add,
}

@JsonSerializable(explicitToJson: true)
class EditChannelRepository {
  @JsonKey(required: true, name: 'company_id')
  String companyId;
  @JsonKey(required: true, name: 'workspace_id')
  String workspaceId;
  @JsonKey(required: true, name: 'channel_id')
  String channelId;
  @JsonKey(required: true)
  String name;
  String icon;
  String description;
  bool def;

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();

  EditChannelRepository({
    @required this.channelId,
    @required this.name,
    this.companyId,
    this.workspaceId,
    this.icon,
    this.description,
    this.def,
  });

  factory EditChannelRepository.fromJson(Map<String, dynamic> json) =>
      _$EditChannelRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$EditChannelRepositoryToJson(this);

  static Future<EditChannelRepository> load() async {
    return EditChannelRepository(channelId: '', name: '');
  }

  Future<void> clear() async {
    companyId = '';
    workspaceId = '';
    name = '';
    icon = '';
    description = '';
    def = true;
  }

  Future<bool> edit() async {
    this.companyId = ProfileBloc.selectedCompany;
    this.workspaceId = ProfileBloc.selectedWorkspace;

    final body = this.toJson();

    _logger.d('Channel editing request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.put(Endpoint.channels, body: body);
    } catch (error) {
      _logger.e('Error while trying to edit a channel:\n${error.message}');
      return false;
    }
    _logger.d('RESPONSE AFTER CHANNEL EDITING: $resp');
    return true;
  }

  Future<bool> delete() async {
    this.companyId = ProfileBloc.selectedCompany;
    this.workspaceId = ProfileBloc.selectedWorkspace;

    final body = <String, dynamic>{
      'company_id': companyId,
      'workspace_id': workspaceId,
      'channel_id': channelId,
    };

    _logger.d('Channel deletion request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.delete(Endpoint.channels, body: body);
    } catch (error) {
      _logger.e('Error while trying to delete a channel:\n${error.message}');
      return false;
    }
    _logger.d('RESPONSE AFTER CHANNEL DELETION: $resp');
    return true;
  }
}
