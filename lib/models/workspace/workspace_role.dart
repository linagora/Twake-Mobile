import 'package:json_annotation/json_annotation.dart';

enum WorkspaceRole {
  @JsonValue('admin')
  admin,
  @JsonValue('member')
  member
}
