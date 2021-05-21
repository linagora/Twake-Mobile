// import 'dart:convert' show jsonEncode, jsonDecode;
//
// import 'package:json_annotation/json_annotation.dart';
// import 'package:twake/models/account_field.dart';
// import 'package:twake/models/language_field.dart';
// import 'package:twake/models/language_option.dart';
// import 'package:twake/models/password_field.dart';
// import 'package:twake/models/password_values.dart';
// import 'package:twake/services/service_bundle.dart';
// import 'package:twake/utils/extensions.dart';
//
// part 'account_repository.g.dart';
//
// const _ACCOUNT_STORE_KEY = 'account';
//
// @JsonSerializable(explicitToJson: true)
// class AccountRepository extends JsonSerializable {
//   @JsonKey(required: true, name: 'username')
//   AccountField? userName;
//   @JsonKey(required: true, name: 'firstname')
//   AccountField? firstName;
//   @JsonKey(required: true, name: 'lastname')
//   AccountField? lastName;
//   LanguageField? language;
//   AccountField? picture;
//   PasswordField? password;
//
//   AccountRepository({
//     this.userName,
//     this.firstName,
//     this.lastName,
//     this.language,
//     this.picture,
//     this.password,
//   });
//
//   @JsonKey(ignore: true)
//   static final _logger = Logger();
//   @JsonKey(ignore: true)
//   static final _api = Api();
//   @JsonKey(ignore: true)
//   static final _storage = Storage();
//   @JsonKey(ignore: true)
//   final _accountMap = <String, dynamic>{};
//
//   // Pseudo constructor for loading account from storage or api
//   static Future<AccountRepository> load() async {
//     // _logger.w("Loading account:");
//     bool loadedFromNetwork = false;
//
//     var accountMap = await _storage.load(
//       type: StorageType.Account,
//       key: _ACCOUNT_STORE_KEY,
//     );
//     if (accountMap == null) {
//       // _logger.d('No account in storage, requesting from api...');
//       accountMap = await (_api.get(Endpoint.account) as FutureOr<Map<String, dynamic>?>);
//       _logger.d('RECEIVED ACCOUNT: $accountMap');
//       loadedFromNetwork = true;
//     } else {
//       accountMap = jsonDecode(accountMap[_storage.settingsField]);
//       _logger.d('RETRIEVED FROM STORAGE ACCOUNT: $accountMap');
//     }
//     // Get repository instance
//     final account = AccountRepository.fromJson(accountMap!);
//     // Save it to store
//     if (loadedFromNetwork) account._save();
//     // return it
//     return account;
//   }
//
//   Future<AccountRepository> reload() async {
//     final accountMap = await _api.get(Endpoint.account);
//     final newRepo = AccountRepository.fromJson(accountMap);
//     userName = newRepo.userName;
//     firstName = newRepo.firstName;
//     lastName = newRepo.lastName;
//     language = newRepo.language;
//     picture = newRepo.picture;
//     _save();
//
//     return this;
//   }
//
//   Future<void> _clean() async {
//     await _storage.delete(
//       type: StorageType.Account,
//       key: _ACCOUNT_STORE_KEY,
//     );
//   }
//
//   Future<void> _save() async {
//     await _storage.store(
//       item: {
//         'id': _ACCOUNT_STORE_KEY,
//         _storage.settingsField: jsonEncode(this.toJson())
//       },
//       type: StorageType.Account,
//     );
//   }
//
//   void update({
//     String newFirstName = '',
//     String newLastName = '',
//     String newLanguage = '',
//     String oldPassword = '',
//     String? newPassword = '',
//     bool shouldUpdateCache = false,
//   }) {
//     if (newFirstName.isNotReallyEmpty) {
//       firstName!.value = newFirstName;
//       _accountMap['firstname'] = newFirstName;
//     }
//     if (newLastName.isNotReallyEmpty) {
//       lastName!.value = newLastName;
//       _accountMap['lastname'] = newLastName;
//     }
//     if (newLanguage.isNotReallyEmpty) {
//       language!.value = newLanguage;
//       _accountMap['language'] = newLanguage;
//     }
//     if (oldPassword.isNotReallyEmpty && newPassword!.isNotReallyEmpty) {
//       _accountMap['password'] = {
//         'old': oldPassword,
//         'new': newPassword,
//       };
//     }
//     if (shouldUpdateCache) _save();
//   }
//
//   Future<AccountRepository> patch() async {
//     print('Data for account update: $_accountMap');
//     final result = await _api.patch(Endpoint.account, body: _accountMap);
//     print('Updated account: ${jsonEncode(result)}');
//     _accountMap.clear();
//     return this;
//   }
//
//   LanguageOption selectedLanguage() {
//     final lang = language!.options
//         .firstWhere((option) => option.value == language!.value, orElse: () {
//       _logger.e(
//           'No matching languages found in options for code: ${language!.value}');
//       return LanguageOption(value: language!.value, title: '');
//     });
//     return lang;
//   }
//
//   String? languageCodeFromTitle(String title) {
//     final lang = language!.options.firstWhere((option) => option.title == title,
//         orElse: () {
//       _logger.e('No matching languages found in options for title: $title');
//       return LanguageOption(value: '', title: title);
//     });
//     return lang.value;
//   }
//
//   /// Convenience methods to avoid deserializing this class from JSON
//   /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
//   factory AccountRepository.fromJson(Map<String, dynamic> json) {
//     return _$AccountRepositoryFromJson(json);
//   }
//
//   /// Convenience methods to avoid serializing this class to JSON
//   /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
//   Map<String, dynamic> toJson() {
//     return _$AccountRepositoryToJson(this);
//   }
// }
