import 'package:json_annotation/json_annotation.dart';

enum CompanyRole {
  @JsonValue('owner')
  owner,

  @JsonValue('admin')
  admin,

  @JsonValue('member')
  member,

  @JsonValue('guest')
  guest,
}
