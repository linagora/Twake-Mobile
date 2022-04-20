import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/globals/channels_type.dart';

part 'globals_hive.g.dart';

@HiveType(typeId: TypeConstant.GLOBALS)
class GlobalsHive extends HiveObject {
  @HiveField(0)
  String host;

  @HiveField(1)
  String? companyId;

  @HiveField(2)
  String? workspaceId;

  @HiveField(3)
  String? channelId;

  @HiveField(4)
  String? threadId;

  @HiveField(5, defaultValue: ChannelsType.commons)
  ChannelsType channelsType;

  @HiveField(6)
  String token;

  @HiveField(7)
  String fcmToken;

  @HiveField(8)
  String? userId;

  @HiveField(9)
  String? clientId;

  @HiveField(10)
  String? oidcAuthority;

  GlobalsHive({
    required this.host,
    required this.channelsType,
    required this.token,
    required this.fcmToken,
    this.userId,
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
    this.clientId,
    this.oidcAuthority,
  });
}
