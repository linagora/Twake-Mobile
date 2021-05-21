import 'package:twake/models/account/account.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/extensions.dart';

class AccountRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  AccountRepository();

  Stream<List<Account>> fetchAccounts({
    required String consoleId,
  }) async* {
    if (consoleId.isEmpty) {
      // TODO: this case should be carefully handled
      print('Accounts fetch failed: console_id is empty');
    } else {
      final localResults = await _storage.select(
        table: Table.account,
        where: 'console_id = ?',
        whereArgs: [consoleId],
      );
      var accounts = localResults
          .map((entry) => Account.fromJson(json: entry))
          .toList();
      yield accounts;

      // TODO: check internet connection here if absent return

      final remoteResults = await _api.get(
        endpoint: Endpoint.account,
        queryParameters: {'console_id': consoleId},
      );
      accounts = remoteResults
          .map((entry) => Account.fromJson(
                json: entry,
                jsonify: false,
              ))
          .toList();

      _storage.multiInsert(table: Table.account, data: accounts);

      yield accounts;
    }
  }

  Future<Account> updateAccount({
    String firstName = '',
    String lastName = '',
    String userName = '',
    String consoleId = '',
    String status = '',
    String statusIcon = '',
    String language = '',
    String oldPassword = '',
    String? newPassword = '',
  }) async {
    final _accountMap = <String, Object?>{};

    if (firstName.isNotReallyEmpty) {
      _accountMap['firstname'] = firstName;
    }
    if (lastName.isNotReallyEmpty) {
      _accountMap['lastname'] = lastName;
    }
    if (userName.isNotReallyEmpty) {
      _accountMap['username'] = userName;
    }
    if (consoleId.isNotReallyEmpty) {
      _accountMap['console_id'] = consoleId;
    }
    if (status.isNotReallyEmpty) {
      _accountMap['status'] = status;
    }
    if (statusIcon.isNotReallyEmpty) {
      _accountMap['status_icon'] = statusIcon;
    }
    if (language.isNotReallyEmpty) {
      _accountMap['language'] = language;
    }
    if (oldPassword.isNotReallyEmpty && newPassword!.isNotReallyEmpty) {
      _accountMap['password'] = {
        'old': oldPassword,
        'new': newPassword,
      };
    }
    final patchResult = await _api.patch(
      endpoint: Endpoint.account,
      data: _accountMap,
    );
    final account = Account.fromJson(json: patchResult, jsonify: false);

    _storage.insert(table: Table.account, data: account);

    return account;
  }

  // LanguageOption selectedLanguage() {
  //   final lang = language!.options
  //       .firstWhere((option) => option.value == language!.value, orElse: () {
  //     _logger.e(
  //         'No matching languages found in options for code: ${language!.value}');
  //     return LanguageOption(value: language!.value, title: '');
  //   });
  //   return lang;
  // }
  //
  // String? languageCodeFromTitle(String title) {
  //   final lang = language!.options.firstWhere((option) => option.title == title,
  //       orElse: () {
  //     _logger.e('No matching languages found in options for title: $title');
  //     return LanguageOption(value: '', title: title);
  //   });
  //   return lang.value;
  // }
}
