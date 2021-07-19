import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/utils/json.dart' as jsn;

export 'account2workspace.dart';

part 'account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Account extends BaseModel {
  final String id;
  final String email;
  final String? firstname;
  final String? lastname;
  final String username;

  @JsonKey(name: 'picture')
  final String? thumbnail;

  @JsonKey(name: 'provider_id')
  final String? consoleId;

  final String? status;
  final String? language;
  final int lastActivity;
  final bool isVerified;
  final bool deleted;

  Account({
    required this.id,
    required this.email,
    this.firstname,
    this.lastname,
    required this.username,
    this.thumbnail,
    this.consoleId,
    this.status,
    this.language,
    required this.lastActivity,
    required this.isVerified,
    required this.deleted,
  });

  int get hash =>
      id.hashCode +
      email.hashCode +
      firstname.hashCode +
      lastname.hashCode +
      username.hashCode +
      thumbnail.hashCode +
      status.hashCode;

  String get fullName => firstname != null && firstname!.isNotEmpty
      ? '$firstname $lastname'
      : username;

  factory Account.fromJson({
    required Map<String, dynamic> json,
    // for future use, in case if composite fields are added
    bool jsonify: false,
    bool transform: false,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: const []);
    }
    return _$AccountFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: false}) {
    var json = _$AccountToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: const []);
    }
    return json;
  }
}
