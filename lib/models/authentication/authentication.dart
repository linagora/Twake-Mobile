import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';

part 'authentication.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Authentication extends BaseModel {
  final String token;
  final String refreshToken;

  final int expiration;
  final int refreshExpiration;

  final String consoleToken;

  final String idToken;

  final String consoleRefresh;

  final int consoleExpiration;

  Authentication({
    required this.token,
    required this.refreshToken,
    required this.expiration,
    required this.refreshExpiration,
    required this.consoleToken,
    required this.idToken,
    required this.consoleRefresh,
    required this.consoleExpiration,
  });

  factory Authentication.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationFromJson(json);

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    return _$AuthenticationToJson(this);
  }
}
