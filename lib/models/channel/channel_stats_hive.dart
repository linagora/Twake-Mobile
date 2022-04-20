import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'channel_stats_hive.g.dart';

@HiveType(typeId: TypeConstant.CHANNEL_STATS)
class ChannelStatsHive extends HiveObject {

  @HiveField(0)
  final int members;

  @HiveField(1)
  final int messages;

  ChannelStatsHive({required this.members, required this.messages});

}