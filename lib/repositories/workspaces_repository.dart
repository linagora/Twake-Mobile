import 'dart:async';

import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';

class WorkspacesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  WorkspacesRepository();

  Future<List<Account>> fetchMembers({
    String? workspaceId,
    bool local: false,
  }) async {
    workspaceId = workspaceId ?? Globals.instance.workspaceId;

    if (local) {
      final sql = '''
        SELECT a.* FROM ${Table.account.name} AS a JOIN
        ${Table.account2workspace.name} AS a2w ON a.id = a2w.user_id
        WHERE a2w.workspace_id = ?''';

      final local = await _storage.rawSelect(sql: sql, args: [workspaceId]);

      return local.map((i) => Account.fromJson(json: i)).toList();
    } else {
      final List<dynamic> remoteResult = await this._api.get(
        endpoint: Endpoint.workspaceMembers,
        queryParameters: {
          'workspace_id': workspaceId,
          'company_id': Globals.instance.companyId
        },
      );

      final List<Account> users = remoteResult
          .map((entry) => Account.fromJson(
                json: entry,
              ))
          .toList();

      this._storage.multiInsert(table: Table.account, data: users);

      this._storage.multiInsert(
          table: Table.account2workspace,
          data: users.map(
            (u) => Account2Workspace(
              userId: u.id,
              workspaceId: workspaceId!,
            ),
          ));

      return users;
    }
  }

  Stream<List<Workspace>> fetch({
    String? companyId,
    bool localOnly: false,
  }) async* {
    if (companyId == null) companyId = Globals.instance.companyId;

    var workspaces = await fetchLocal(companyId: companyId!);

    yield workspaces;

    if (!Globals.instance.isNetworkConnected || localOnly) return;

    final rworkspaces = await fetchRemote(companyId: companyId);

    yield workspaces;

    if (rworkspaces.length != workspaces.length) {
      for (final w in workspaces) {
        if (!rworkspaces.any((rw) => rw.id == w.id)) {
          _storage.delete(
            table: Table.workspace,
            where: 'id = ?',
            whereArgs: [w.id],
          );
        }
      }
    }
  }

  Future<List<Workspace>> fetchLocal({required String companyId}) async {
    final localResult = await this._storage.select(
      table: Table.workspace,
      where: 'company_id = ?',
      whereArgs: [companyId],
    );

    final workspaces =
        localResult.map((entry) => Workspace.fromJson(json: entry)).toList();

    return workspaces;
  }

  Future<List<Workspace>> fetchRemote({required String companyId}) async {
    final List<dynamic> remoteResult = await this._api.get(
          endpoint: sprintf(Endpoint.workspaces, [companyId]),
          key: 'resources',
        );

    final List<Workspace> workspaces = remoteResult
        .map((entry) => Workspace.fromJson(
              json: entry,
              transform: true,
            ))
        .toList();

    _storage.multiInsert(table: Table.workspace, data: workspaces);

    return workspaces;
  }

  Future<Workspace> createWorkspace(
      {String? companyId, required String name, List<String>? members}) async {
    companyId = companyId ?? Globals.instance.companyId;

    final creationResult = await this._api.post(
      endpoint: sprintf(Endpoint.workspaces, [companyId]),
      data: {'company_id': companyId, 'name': name, 'members': members},
    );

    final workspace = Workspace.fromJson(json: creationResult, transform: true);

    _storage.insert(table: Table.workspace, data: workspace);

    return workspace;
  }
}
