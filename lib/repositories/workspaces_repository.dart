import 'dart:async';

import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';

class WorkspacesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  WorkspacesRepository();

  Future<List<Account>> fetchMembers({String? workspaceId}) async {
    workspaceId = workspaceId ?? Globals.instance.workspaceId;

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
              jsonify: false,
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

  Stream<List<Workspace>> fetch({String? companyId}) async* {
    if (companyId == null) companyId = Globals.instance.companyId;

    var workspaces = await fetchLocal(companyId: companyId!);
    yield workspaces;

    if (!Globals.instance.isNetworkConnected) return;

    workspaces = await fetchRemote(companyId: companyId);

    yield workspaces;
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
      endpoint: Endpoint.workspaces,
      queryParameters: {'company_id': companyId},
    );

    final List<Workspace> workspaces = remoteResult
        .map((entry) => Workspace.fromJson(
              json: entry,
              jsonify: false,
            ))
        .toList();

    _storage.multiInsert(table: Table.workspace, data: workspaces);

    return workspaces;
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

    _storage.insert(table: Table.workspace, data: workspace);

    return workspace;
  }
}
