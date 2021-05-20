import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'channels_type.dart';
import 'tabs.dart';

export 'channels_type.dart';
export 'tabs.dart';

part 'globals.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Globals extends BaseModel {
  static late Globals _globals;

  String host;
  String? companyId;
  String? workspaceId;
  String? channelId;
  String? threadId;

  // type of the channels selected in main chats view: commons (public/private) or directs
  @JsonKey(defaultValue: ChannelsType.Commons)
  ChannelsType channelsType;

  // tab which is currently selected in lower part of the app screen
  @JsonKey(defaultValue: Tabs.Channels)
  Tabs tabs;

  // JWToken
  String token;
  String fcmToken;
  String userId;

  // Make sure to call the factory constructor before accessing instance
  static Globals get instance {
    return _globals;
  }

  factory Globals({
    required String host,
    required ChannelsType channelsType,
    required Tabs tabs,
    required String token,
    required String fcmToken,
    required String userId,
    String? companyId,
    String? workspaceId,
    String? channelId,
    String? threadId,
  }) {
    _globals = Globals._(
      host: host,
      channelsType: channelsType,
      tabs: tabs,
      token: token,
      fcmToken: fcmToken,
      userId: userId,
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
    );
    return _globals;
  }

  Globals._({
    required this.host,
    required this.channelsType,
    required this.tabs,
    required this.token,
    required this.fcmToken,
    required this.userId,
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
  });

  factory Globals.fromJson(Map<String, dynamic> json) =>
      _$GlobalsFromJson(json);

  @override
  Map<String, dynamic> toJson({stringify: true}) => _$GlobalsToJson(this);
}
