import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'pinned_info_hive.g.dart';

@HiveType(typeId: TypeConstant.MESSAGE_PINNED_INFO)
class PinnedInfoHive extends HiveObject {
  @HiveField(0)
  final String pinnedBy;
  @HiveField(1)
  final int pinnedAt;

  PinnedInfoHive({
    required this.pinnedBy,
    required this.pinnedAt,
  });
}
