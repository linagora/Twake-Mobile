import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'workspace_role.g.dart';

@HiveType(typeId: TypeConstant.WORKSPACE_ROLE)
enum WorkspaceRole {
  @HiveField(0)
  @JsonValue('moderator')
  moderator,

  @HiveField(1)
  @JsonValue('member')
  member
}
