import 'dart:async';

import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';

class WorkspacesRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  final _workspaceStreamController = StreamController<List<Workspace>>();

  // register to this stream to get workspace updates;
  Stream<List<Workspace>> get workspaceStream =>
      _workspaceStreamController.stream;

  WorkspacesRepository();

  Future<List<Account>> fetchMembers({String? workspaceId}) async {
    final List<Map<String, Object?>> members = await this._api.get(
      endpoint: Endpoint.workspaceMembers,
      queryParameters: {
        'workspace_id': workspaceId ?? Globals.instance.workspaceId,
        'company_id': Globals.instance.companyId
      },
    );
    final List<Account> users = [];
    for (final m in members) {
      users.add(Account.fromJson(json: m));
    }
    this._storage.multiInsert(table: Table.account, data: users);

    return users;
  }

  void fetch({String? companyId}) async {
    final localResult = await this._storage.select(
      table: Table.workspace,
      where: 'company_id = ?',
      whereArgs: [companyId],
    );
    var workspaces =
        localResult.map((entry) => Workspace.fromJson(json: entry)).toList();
    _workspaceStreamController.sink.add(workspaces);

    if (!Globals.instance.isNetworkConnected) return;

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
    _workspaceStreamController.sink.add(workspaces);
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

  void closeStream() async {
    await _workspaceStreamController.close();
  }
}
