import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/utils/api_data_transformer.dart';

export 'account2workspace.dart';

part 'account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Account extends BaseModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String username;

  final String? picture;

  final String? providerId;

  final String? status;
  final String? language;
  final int lastActivity;

  @JsonKey(name: 'is_verified')
  int _isVerified = 0;
  @JsonKey(name: 'deleted')
  int _deleted = 0;

  Account({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.username,
    this.picture,
    this.providerId,
    this.status,
    this.language,
    required this.lastActivity,
  });

  int get hash =>
      id.hashCode +
      email.hashCode +
      firstName.hashCode +
      lastName.hashCode +
      username.hashCode +
      picture.hashCode +
      status.hashCode;

  String get fullName => firstName != null && firstName!.isNotEmpty
      ? '$firstName $lastName'
      : username;

  @JsonKey(ignore: true)
  bool get isVerified => _isVerified > 0;

  @JsonKey(ignore: true)
  bool get deleted => _deleted > 0;

  factory Account.fromJson({
    required Map<String, dynamic> json,
    // for future use, in case if composite fields are added
    bool jsonify: false,
    bool transform: false,
  }) {
    if (transform) {
      json = ApiDataTransformer.account(json: json);
    }
    return _$AccountFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: false}) {
    var json = _$AccountToJson(this);
    return json;
  }
}
