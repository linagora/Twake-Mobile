import 'package:hive/hive.dart';
import 'package:twake/data/local/type_constants.dart';

part 'authentication_hive.g.dart';

@HiveType(typeId: TypeConstant.AUTHENTICATION)
class AuthenticationHive extends HiveObject {
  @HiveField(0)
  final String token;

  @HiveField(1)
  final String refreshToken;

  @HiveField(2)
  final int expiration;

  @HiveField(3)
  final int refreshExpiration;

  @HiveField(4)
  final String consoleToken;

  @HiveField(5)
  final String idToken;

  @HiveField(6)
  final String consoleRefresh;

  @HiveField(7)
  final int consoleExpiration;

  AuthenticationHive(
      {required this.token,
      required this.refreshToken,
      required this.expiration,
      required this.refreshExpiration,
      required this.consoleToken,
      required this.idToken,
      required this.consoleRefresh,
      required this.consoleExpiration});
}
