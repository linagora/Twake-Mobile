import 'package:json_annotation/json_annotation.dart';

enum WorkspaceRole {
  @JsonValue('moderator')
  moderator,
  @JsonValue('member')
  member
}
