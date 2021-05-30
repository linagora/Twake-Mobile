import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class AccountRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  AccountRepository();

  Stream<Account> fetch({required String userId}) async* {
    final localResult = await _storage.first(
      table: Table.account,
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (localResult.isNotEmpty) {
      yield Account.fromJson(json: localResult);
    }

    if (!Globals.instance.isNetworkConnected) return;

    final remoteResult = await _api.get(
      endpoint: Endpoint.account,
      queryParameters: {'id': userId},
    );

    var account = Account.fromJson(json: remoteResult);

    _storage.insert(table: Table.account, data: account);

    yield account;
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
}
