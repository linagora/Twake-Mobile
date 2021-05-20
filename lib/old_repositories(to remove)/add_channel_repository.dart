import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/endpoints.dart';

part 'add_channel_repository.g.dart';

enum FlowStage {
  info,
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
  String? companyId;
  @JsonKey(required: true, name: 'workspace_id')
  String? workspaceId;
  @JsonKey(required: true)
  String? name;
  @JsonKey(required: false, defaultValue: 'public')
  String? visibility;

  @JsonKey(required: false)
  String? icon;
  @JsonKey(required: false)
  String? description;
  @JsonKey(required: false, name: 'channel_group')
  String? channelGroup;
  @JsonKey(required: false, name: 'default')
  bool? def;
  @JsonKey(required: false)
  List<String?>? members;

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  ChannelType? type;

  AddChannelRepository({
    required this.companyId,
    required this.workspaceId,
    required this.name,
    this.visibility,
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
    return AddChannelRepository(companyId: '', workspaceId: '', name: '');
  }

  Future<void> clear() async {
    companyId = '';
    workspaceId = '';
    name = '';
    visibility = '';
    icon = '';
    description = '';
    channelGroup = '';
    members = [];
    type = ChannelType.public;
  }

  Future<String?> create() async {
    this.companyId = ProfileBloc.selectedCompanyId;
    this.workspaceId = ProfileBloc.selectedWorkspaceId;

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

    if (this.name!.isEmpty) {
      this.workspaceId = 'direct';
      this.visibility = 'direct';
    }

    final body = this.toJson();
    _logger.d('Channel creation request body: $body');
    Map<String, dynamic>? resp;
    try {
      resp = await (_api.post(Endpoint.channels, body: body) as FutureOr<Map<String, dynamic>?>);
    } catch (error) {
      _logger.e('Error while trying to create a channel:\n${error.message}');
      return '';
    }
    _logger.d('RESPONSE AFTER CHANNEL CREATION: $resp');
    String? channelId = resp!['id'];
    return channelId;
  }
}