import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/badge/badge.dart';

part 'badge_hive.g.dart';

@HiveType(typeId: TypeConstant.BADGE)
class BadgeHive extends HiveObject {
  @HiveField(0)
  final BadgeType type;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final int? count;

  BadgeHive({required this.type, required this.id, this.count});
}
