import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/services/storage/storage.dart';

part 'add_channel_repository.g.dart';

enum FlowStage {
  info,
  groups,
  type,
  participants,
}

enum ChannelType {
  public,
  private,
  direct,
}

@JsonSerializable(explicitToJson: true)
class AddChannelRepository {
  @JsonKey(required: true, name: 'company_id')
  String companyId;
  @JsonKey(required: true, name: 'workspace_id')
  String workspaceId;
  @JsonKey(required: true)
  String name;
  @JsonKey(required: true)
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
  static final _storage = Storage();
  @JsonKey(ignore: true)
  FlowStage flow;
  @JsonKey(ignore: true)
  ChannelType type;

  AddChannelRepository(
    this.companyId,
    this.workspaceId,
    this.name,
    this.visibility, {
    this.icon,
    this.description,
    this.channelGroup,
    this.def,
    this.members,
    this.type,
  });

  factory AddChannelRepository.fromJson(Map<String, dynamic> json) =>
      _$AddChannelRepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$AddChannelRepositoryToJson(this);

  static Future<AddChannelRepository> load() async {
    return AddChannelRepository('', '', '', '');
  }

  // Future<AddChannelData> load() async {
  //
  // }

  void setStage(FlowStage flow) {
    this.flow = flow;
  }

  Future<void> cache() async {}

  Future<void> clear() async {
    companyId = '';
    workspaceId = '';
    name = '';
    visibility = '';
    icon = '';
    description = '';
    channelGroup = '';
    def = false;
    members = [];
    flow = FlowStage.info;
    type = ChannelType.public;
  }

  Future<bool> create() async {
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

    String myId = ProfileBloc.userId;
    this.members.add(myId);

    // if (this.name.isEmpty ||
    //     this.companyId.isEmpty ||
    //     this.workspaceId.isEmpty ||
    //     this.visibility.isEmpty) {
    //   _logger.d(
    //       'Channel creation: validation error. Not all mandatory fields exist in request body.');
    //   return false;
    // } else {
      final channelJson = this.toJson();
      return process(channelJson);
    // }
  }

  Future<bool> process(Map<String, dynamic> body) async {
    _logger.d('Channel creation request...');
    var resp;
    try {
      resp = await _api.post(Endpoint.channels, body: body);
    } catch (error) {
      _logger.e('Error while trying to create a channel:\n${error.message}');
      return false;
    }
    _logger.d('RESPONSE AFTER CHANNEL CREATION: $resp');
    return true;
  }
}
