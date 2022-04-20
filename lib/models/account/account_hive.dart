import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'account_hive.g.dart';

@HiveType(typeId: TypeConstant.ACCOUNT)
class AccountHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? firstName;

  @HiveField(3)
  final String? lastName;

  @HiveField(4)
  final String? username;

  @HiveField(5)
  final String? picture;

  @HiveField(6)
  final String? providerId;

  @HiveField(7)
  final String? status;

  @HiveField(8)
  final String? language;

  @HiveField(9)
  final int? lastActivity;

  @HiveField(10)
  final String? recentWorkspaceId;

  @HiveField(11)
  final String? recentCompanyId;

  @HiveField(12)
  final int? verified;

  @HiveField(13)
  final int? deleted;

  AccountHive(
      {required this.id,
      required this.email,
      this.firstName,
      this.lastName,
      this.username,
      this.verified,
      this.deleted,
      this.picture,
      this.providerId,
      this.status,
      this.language,
      this.lastActivity,
      this.recentWorkspaceId,
      this.recentCompanyId});
}
