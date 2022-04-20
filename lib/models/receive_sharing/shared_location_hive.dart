import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'shared_location_hive.g.dart';

@HiveType(typeId: TypeConstant.SHAREDLOCATION)
class SharedLocationHive extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String companyId;

  @HiveField(2)
  final String workspaceId;

  @HiveField(3)
  final String channelId;

  SharedLocationHive({
    this.id,
    required this.companyId,
    required this.workspaceId,
    required this.channelId,
  });
}
