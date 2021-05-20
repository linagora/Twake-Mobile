import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/user_account/user_account.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/extensions.dart';


class AccountRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  AccountRepository();

  Future<UserAccount> getAccount() async {
    final Map<String, Object?> accountMap =
        await this._api.get(endpoint: Endpoint.account);
    final account = UserAccount.fromJson(json: accountMap);
    this._storage.insert(table: Table.userAccount, data: account);
    return account;
  }

  // required this.id,
  // required this.email,
  // this.firstname,
  // this.lastname,
  // required this.username,
  // this.thumbnail,
  // this.consoleId,
  // this.status,
  // this.statusIcon,
  // this.language,
  // required this.lastActivity,
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
    bool shouldUpdateCache = false,
  }) async {
    final _accountMap = <String, dynamic>{};

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
    if (shouldUpdateCache) _save();
  }

  Stream<List<Workspace>> getWorkspaces({String? companyId}) async* {
    final localResult = await this._storage.select(
      table: Table.workspace,
      where: 'company_id = ?',
      whereArgs: [companyId],
    );
    var workspaces =
        localResult.map((entry) => Workspace.fromJson(json: entry)).toList();
    yield workspaces;

    // TODO check internet connection here if absent return

    final remoteResult = await this._api.get(
      endpoint: Endpoint.workspaces,
      queryParameters: {'company_id': companyId ?? Globals.instance.companyId},
    );
    workspaces = remoteResult
        .map((entry) => Workspace.fromJson(
              json: entry,
              jsonify: false,
            ))
        .toList();
    yield workspaces;
  }

  Future<Workspace> createWorkspace(
      {String? companyId, required String name, List<String>? members}) async {
    final creationResult = await this._api.post(
      endpoint: Endpoint.workspaces,
      data: {
        'company_id': companyId ?? Globals.instance.companyId,
        'name': name,
        'members': members
      },
    );

    final workspace = Workspace.fromJson(json: creationResult, jsonify: false);
    return workspace;
  }
}
