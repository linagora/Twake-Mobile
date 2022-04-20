import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';
import 'package:twake/models/company/company_role.dart';

part 'company_hive.g.dart';

@HiveType(typeId: TypeConstant.COMPANY)
class CompanyHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? logo;

  @HiveField(3, defaultValue: 0)
  final int totalMembers;

  @HiveField(4)
  final CompanyRole role;

  @HiveField(5)
  String? selectedWorkspace;

  CompanyHive({
    required this.id,
    required this.name,
    required this.totalMembers,
    this.logo,
    this.selectedWorkspace,
    required this.role,
  });
}
