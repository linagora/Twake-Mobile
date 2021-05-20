import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/user_account/user_account.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';

class WorkspacesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  WorkspacesRepository();

  Future<List<UserAccount>> getMembersList({String? workspaceId}) async {
    final List<Map<String, Object?>> members = await this._api.get(
      endpoint: Endpoint.workspaceMembers,
      queryParameters: {
        'workspace_id': workspaceId ?? Globals.instance.workspaceId,
        'company_id': Globals.instance.companyId
      },
    );
    final List<UserAccount> users = [];
    for (final m in members) {
      users.add(UserAccount.fromJson(json: m));
    }
    this._storage.multiInsert(table: Table.userAccount, data: users);

    return users;
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
