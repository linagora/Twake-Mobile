import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class AccountRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  AccountRepository();

  // userId can be null for current app user on first login
  Stream<Account> fetch({String? userId}) async* {
    Account account;
    if (userId != null) {
      account = await localFetch(userId: userId);
      yield account;
    }

    if (!Globals.instance.isNetworkConnected) return;

    account = await remoteFetch(userId: userId);

    yield account;
  }

  Future<Account> localFetch({required String userId}) async {
    final localResult = await _storage.first(
      table: Table.account,
      where: 'id = ?',
      whereArgs: [userId],
    );

    return Account.fromJson(json: localResult);
  }

  Future<Account> remoteFetch({String? userId}) async {
    final remoteResult = await _api.get(
      endpoint: Endpoint.account,
      queryParameters: {'id': userId},
    );

    final account = Account.fromJson(json: remoteResult);

    _storage.insert(table: Table.account, data: account);

    return account;
  }

  Future<Account> edit({
    String? firstname,
    String? lastname,
    required String username,
    String? status,
    String? statusIcon,
    String? language,
    String? oldPassword,
    String? newPassword,
  }) async {
    final _ = {
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'status': status,
      'status_icon': statusIcon,
      'language': language,
      'password': {
        'old': oldPassword,
        'new': newPassword,
      },
    };

    throw Exception('Moved to Twake console for a while');
  }

  Future<void> currentSet() async {
    final remoteResult = await _api.get(
      endpoint: Endpoint.account,
    );

    var account = Account.fromJson(json: remoteResult);

    _storage.insert(table: Table.account, data: account);

    Globals.instance.userIdSet = account.id;
  }
}
