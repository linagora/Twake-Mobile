import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/channel/channel_role.dart';
import 'package:twake/models/channel/channel_stats.dart';
import 'package:twake/models/channel/channel_visibility.dart';
import 'package:twake/models/message/message_summary.dart';

part 'channel_hive.g.dart';

@HiveType(typeId: TypeConstant.CHANNEL)
class ChannelHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1, defaultValue: '')
  final String name;

  @HiveField(2)
  final String? icon;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String companyId;

  @HiveField(5)
  final String workspaceId;

  @HiveField(6)
  final List<String> members;

  @HiveField(7, defaultValue: 0)
  final int membersCount;

  @HiveField(8, defaultValue: ChannelVisibility.public)
  final ChannelVisibility visibility;

  @HiveField(9)
  final int lastActivity;

  @HiveField(10)
  final MessageSummary? lastMessage;

  @HiveField(11, defaultValue: 0)
  final int userLastAccess;

  @HiveField(12)
  String? draft;

  @HiveField(13, defaultValue: ChannelRole.member)
  final ChannelRole role;

  @HiveField(14)
  final ChannelStats? stats;

  ChannelHive(
      {required this.id,
      required this.name,
      this.icon,
      this.description,
      required this.companyId,
      required this.workspaceId,
      this.lastMessage,
      required this.members,
      required this.visibility,
      required this.lastActivity,
      required this.membersCount,
      required this.role,
      this.userLastAccess: 0,
      this.draft,
      this.stats});
}
