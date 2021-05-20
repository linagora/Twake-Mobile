import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/utils/json.dart' as jsn;

part 'user_account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserAccount extends BaseModel {
  final String id;
  final String email;
  final String? firstname;
  final String? lastname;
  final String username;
  final String? thumbnail;
  final String? consoleId;
  final String? statusIcon;
  final String? status;
  final String language;

  UserAccount({
    required this.id,
    required this.email,
    this.firstname,
    this.lastname,
    required this.username,
    this.thumbnail,
    this.consoleId,
    this.status,
    this.statusIcon,
    required this.language,
  });

  factory UserAccount.fromJson({
    required Map<String, dynamic> json,
    // for future use, in case if composite fields are added
    bool jsonify: false,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: const []);
    }
    return _$UserAccountFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: false}) {
    var json = _$UserAccountToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: const []);
    }
    return json;
  }
}
