import 'package:json_annotation/json_annotation.dart';
import 'channels_type.dart';
import 'tabs.dart';

export 'channels_type.dart';
export 'tabs.dart';

part 'globals.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Globals {
  static Globals? _globals;

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

  String jwtoken;
  String fcmtoken;
  String userId;

  // return value is guarranted to be a valid instance
  Globals? get instance {
    if (_globals == null)
      throw Exception('Globals instance is not initialized!');
    return _globals;
  }

  factory Globals({
    required String host,
    required ChannelsType channelsType,
    required Tabs tabs,
    required String jwtoken,
    required String fcmtoken,
    required String userId,
    String? companyId,
    String? workspaceId,
    String? channelId,
    String? threadId,
  }) {
    return _globals ??= Globals._(
      host: host,
      channelsType: channelsType,
      tabs: tabs,
      jwtoken: jwtoken,
      fcmtoken: fcmtoken,
      userId: userId,
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
    );
  }

  Globals._({
    required this.host,
    required this.channelsType,
    required this.tabs,
    required this.jwtoken,
    required this.fcmtoken,
    required this.userId,
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
  });

  factory Globals.fromJson(Map<String, dynamic> json) =>
      _$GlobalsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalsToJson(this);
}
