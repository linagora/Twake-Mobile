import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'account2workspace_hive.g.dart';

@HiveType(typeId: TypeConstant.ACCOUNT2WORKSPACE)
class Account2WorkspaceHive extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String workspaceId;

  Account2WorkspaceHive({required this.userId, required this.workspaceId});

}
