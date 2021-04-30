import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/account_field.dart';
import 'package:twake/models/language_field.dart';
import 'package:twake/models/language_option.dart';
import 'package:twake/models/password_field.dart';
import 'package:twake/models/password_values.dart';

// import 'package:twake/models/base_channel.dart';
// import 'package:twake/models/company.dart';
// import 'package:twake/models/workspace.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/extensions.dart';

part 'account_repository.g.dart';

const _ACCOUNT_STORE_KEY = 'account';

@JsonSerializable(explicitToJson: true)
class AccountRepository extends JsonSerializable {
  @JsonKey(required: true, name: 'username')
  AccountField userName;
  @JsonKey(required: true, name: 'firstname')
  AccountField firstName;
  @JsonKey(required: true, name: 'lastname')
  AccountField lastName;
  @JsonKey(required: false)
  LanguageField language;
  @JsonKey(required: false)
  AccountField picture;
  @JsonKey(required: false)
  PasswordField password;

  AccountRepository({
    this.userName,
    this.firstName,
    this.lastName,
    this.language,
    this.picture,
    this.password,
  });

  @JsonKey(ignore: true)
  static final _logger = Logger();
  @JsonKey(ignore: true)
  static final _api = Api();
  @JsonKey(ignore: true)
  static final _storage = Storage();

  // Pseudo constructor for loading profile from storage or api
  static Future<AccountRepository> load() async {
    // _logger.w("Loading account:");
    var accountMap = await _storage.load(
      type: StorageType.Account,
      key: _ACCOUNT_STORE_KEY,
    );
    if (accountMap == null) {
      // _logger.d('No account in storage, requesting from api...');
      accountMap = await _api.get(Endpoint.account);
      // _logger.d('RECEIVED ACCOUNT: $accountMap');
    } else {
      accountMap = jsonDecode(accountMap[_storage.settingsField]);
      // _logger.d('RETRIEVED ACCOUNT: $accountMap');
    }
    // Get repository instance
    final account = AccountRepository.fromJson(accountMap);
    // Save it to store
    // if (loadedFromNetwork) account.save();
    // return it
    return account;
  }

  Future<AccountRepository> reload() async {
    final profileMap = await _api.get(Endpoint.account);
    // _update(profileMap);
    final newRepo = AccountRepository.fromJson(profileMap);
    userName = newRepo.userName;
    firstName = newRepo.firstName;
    lastName = newRepo.lastName;
    language = newRepo.language;
    picture = newRepo.picture;

    return this;
  }

  Future<void> clean() async {
    await _storage.delete(
      type: StorageType.Account,
      key: _ACCOUNT_STORE_KEY,
    );
  }

  Future<void> save() async {
    await _storage.store(
      item: {
        'id': _ACCOUNT_STORE_KEY,
        _storage.settingsField: jsonEncode(this.toJson())
      },
      type: StorageType.Account,
    );
  }

  Future<AccountRepository> patch({
    String newFirstName,
    String newLastName,
    String newLanguage,
    String oldPassword,
    String newPassword,
  }) async {
    final Map<String, dynamic> accountMap = <String, dynamic>{};
    if (newFirstName != null && newFirstName.isNotReallyEmpty) {
      firstName.value = newFirstName;
      accountMap['firstname'] = newFirstName;
    }
    if (newLastName != null && newLastName.isNotReallyEmpty) {
      lastName.value = newLastName;
      accountMap['lastname'] = newLastName;
    }
    if (newLanguage != null && newLanguage.isNotReallyEmpty) {
      language.value = newLanguage;
      accountMap['language'] = newLanguage;
    }
    if (oldPassword != null &&
        newPassword != null &&
        oldPassword.isNotReallyEmpty &&
        newPassword.isNotReallyEmpty) {
      password = PasswordField(
        isReadonly: password.isReadonly,
        value: PasswordValues(
          oldPass: oldPassword,
          newPass: newPassword,
        ),
      );
      accountMap['password'] = {
        'old': oldPassword,
        'new': newPassword,
      };
    }
    final result = await _api.patch(Endpoint.account, body: toJson());
    if (result != null) {
      print('Account updated: $accountMap');
      // save();
    }
    return this;
  }

  LanguageOption selectedLanguage() {
    final lang = language.options
        .firstWhere((option) => option.value == language.value, orElse: () {
      _logger.e(
          'No matching languages found in options for code: ${language.value}');
      return LanguageOption(value: language.value, title: 'unknown');
    });
    return lang;
  }

  String languageCodeFromTitle(String title) {
    final lang = language.options.firstWhere((option) => option.title == title,
        orElse: () {
          _logger.e('No matching languages found in options for title: $title');
          return LanguageOption(value: 'unknown', title: title);
        });
    return lang.value;
  }

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory AccountRepository.fromJson(Map<String, dynamic> json) {
    // json = Map.from(json);
    // if (json['notification_rooms'] is String) {
    // json['notification_rooms'] = jsonDecode(json['notification_rooms']);
    // }
    return _$AccountRepositoryFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$AccountRepositoryToJson(this);
    // map['notification_rooms'] = jsonEncode(map['notification_rooms']);
    return map;
  }
}
