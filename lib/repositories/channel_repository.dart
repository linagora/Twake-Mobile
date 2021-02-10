import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';

part 'channel_repository.g.dart';

enum FlowStage {
  info,
  participants,
}

enum EditFlowStage {
  manage,
  add,
}

enum ChannelType {
  public,
  private,
  direct,
}

@JsonSerializable(explicitToJson: true)
class ChannelRepository {
  @JsonKey(required: true, name: 'company_id')
  String companyId;
  @JsonKey(required: true, name: 'workspace_id')
  String workspaceId;
  @JsonKey(required: true)
  String name;
  @JsonKey(required: false, defaultValue: 'public')
  String visibility;

  @JsonKey(required: false)
  String icon;
  @JsonKey(required: false)
  String description;
  @JsonKey(required: false, name: 'channel_group')
  String channelGroup;
  @JsonKey(required: false, name: 'default')
  bool def;
  @JsonKey(required: false)
  List<String> members;

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  ChannelType type;

  ChannelRepository(
    this.companyId,
    this.workspaceId,
    this.name, {
    this.visibility,
    this.icon,
    this.description,
    this.channelGroup,
    this.def,
    this.members,
    this.type,
  });

  factory ChannelRepository.fromJson(Map<String, dynamic> json) =>
      _$ChannelRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelRepositoryToJson(this);

  static Future<ChannelRepository> load() async {
    return ChannelRepository('', '', '',);
  }

  // Future<AddChannelData> load() async {
  //
  // }

  Future<void> clear() async {
    companyId = '';
    workspaceId = '';
    name = '';
    visibility = '';
    icon = '';
    description = '';
    channelGroup = '';
    def = true;
    members = [];
    type = ChannelType.public;
  }

  Future<String> create() async {
    this.companyId = ProfileBloc.selectedCompany;
    this.workspaceId = ProfileBloc.selectedWorkspace;

    switch (type) {
      case ChannelType.public:
        this.visibility = 'public';
        break;
      case ChannelType.private:
        this.visibility = 'private';
        break;
      case ChannelType.direct:
        this.visibility = 'direct';
        this.workspaceId = 'direct';
        break;
    }

    if (this.name.isEmpty) {
      this.workspaceId = 'direct';
      this.visibility = 'direct';
    }

    // String myId = ProfileBloc.userId;
    // this.members.add(myId);

    // if (this.name.isEmpty ||
    //     this.companyId.isEmpty ||
    //     this.workspaceId.isEmpty ||
    //     this.visibility.isEmpty) {
    //   _logger.d(
    //       'Channel creation: validation error. Not all mandatory fields exist in request body.');
    //   return false;
    // } else {
    final addChannelJson = this.toJson();
    return process(addChannelJson);
    // }
  }

  Future<bool> updateMembers({
    @required List<String> members,
    @required String channelId,
  }) async {
    String companyId = ProfileBloc.selectedCompany;
    String workspaceId = ProfileBloc.selectedWorkspace;

    final body = <String, dynamic>{
      'company_id': companyId,
      'workspace_id': workspaceId,
      'channel_id': channelId,
      'members': members,
    };
    _logger.d('Members update request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.post(Endpoint.channelMembers, body: body);
    } catch (error) {
      _logger.e('Error while trying to update members of a channel: $error');
      return false;
    }
    _logger.d('RESPONSE AFTER MEMBERS UPDATE: $resp');
    return true;
  }

  Future<bool> fetchMembers({
    @required String channelId,
  }) async {
    String companyId = ProfileBloc.selectedCompany;
    String workspaceId = ProfileBloc.selectedWorkspace;

    final queryParams = <String, dynamic>{
      'company_id': companyId,
      'workspace_id': workspaceId,
      'channel_id': channelId,
    };
    _logger.d('Members fetch query parameters: $queryParams');
    Map<String, dynamic> resp;
    try {
      resp = await _api.get(Endpoint.channelMembers, params: queryParams);
    } catch (error) {
      _logger.e('Error while trying to fetch members of a channel: $error');
      return false;
    }
    _logger.d('RESPONSE AFTER MEMBERS FETCH: $resp');
    return true;
  }


  Future<String> process(Map<String, dynamic> body) async {
    _logger.d('Channel creation request body: $body');
    Map<String, dynamic> resp;
    try {
      resp = await _api.post(Endpoint.channels, body: body);
    } catch (error) {
      _logger.e('Error while trying to create a channel:\n${error.message}');
      return '';
    }
    _logger.d('RESPONSE AFTER CHANNEL CREATION: $resp');
    String channelId = resp['id'];
    return channelId;
  }

  Future<bool> edit(Map<String, dynamic> body) async {
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
}
