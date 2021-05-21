import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/user_account/user_account.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/extensions.dart';

class AccountRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  AccountRepository();

  Stream<List<UserAccount>> fetchAccounts({
    required String consoleId,
  }) async* {
    if (consoleId.isEmpty) {
      // TODO: this case should be carefully handled
      print('Accounts fetch failed: console_id is empty');
    } else {
      final localResults = await _storage.select(
        table: Table.userAccount,
        where: 'console_id = ?',
        whereArgs: [consoleId],
      );
      var accounts = localResults
          .map((entry) => UserAccount.fromJson(json: entry))
          .toList();
      yield accounts;

      // TODO: check internet connection here if absent return

      final remoteResults = await _api.get(
        endpoint: Endpoint.account,
        queryParameters: {'console_id': consoleId},
      );
      accounts = remoteResults
          .map((entry) => UserAccount.fromJson(
                json: entry,
                jsonify: false,
              ))
          .toList();

      _storage.multiInsert(table: Table.userAccount, data: accounts);

      yield accounts;
    }
  }

  Future<UserAccount> updateAccount({
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
    final account = UserAccount.fromJson(json: patchResult, jsonify: false);

    _storage.insert(table: Table.userAccount, data: account);

    return account;
  }
}
