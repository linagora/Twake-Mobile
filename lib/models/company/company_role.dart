import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'company_role.g.dart';

@HiveType(typeId: TypeConstant.COMPANY_ROLE)
enum CompanyRole {
  @HiveField(0)
  @JsonValue('owner')
  owner,

  @HiveField(1)
  @JsonValue('admin')
  admin,

  @HiveField(2)
  @JsonValue('member')
  member,

  @HiveField(3)
  @JsonValue('guest')
  guest,
}
