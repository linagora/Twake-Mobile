import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/workspace/workspace_role.dart';

part 'workspace_hive.g.dart';

@HiveType(typeId: TypeConstant.WORKSPACE)
class WorkspaceHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1, defaultValue: '')
  final String name;

  @HiveField(2)
  final String? logo;

  @HiveField(3)
  final String companyId;

  @HiveField(4, defaultValue: 0)
  final int totalMembers;

  @HiveField(5, defaultValue: WorkspaceRole.member)
  final WorkspaceRole role;

  WorkspaceHive({
    required this.id,
    required this.name,
    this.logo,
    required this.companyId,
    required this.totalMembers,
    required this.role,
  });
}
