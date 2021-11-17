import 'dart:async';

import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/invitation/email_invitation.dart';
import 'package:twake/models/invitation/email_invitation_response.dart';
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
        SELECT DISTINCT a.id, a.* FROM ${Table.account.name} AS a JOIN
        ${Table.account2workspace.name} AS a2w ON a.id = a2w.user_id
        JOIN ${Table.workspace.name} AS w ON w.id = a2w.workspace_id
        WHERE w.company_id = ?''';

      final local = await _storage.rawSelect(
        sql: sql,
        args: [Globals.instance.companyId],
      );

      return local.map((i) => Account.fromJson(json: i)).toList();
    } else {
      final List<dynamic> remoteResult = await _api.get(
        endpoint: sprintf(
          Endpoint.workspaceMembers,
          [Globals.instance.companyId, workspaceId],
        ),
        queryParameters: {'limit': 10000},
        key: 'resources',
      );

      final List<Account> users = remoteResult
          .map((entry) => Account.fromJson(
                json: entry['user'],
                transform: true,
              ))
          .toList();

      // Select a language from the database before rewriting it
      final dataL = await _storage.select(
          table: Table.account,
          columns: ["language"],
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);

      // Update account info from remote to local db (with null language field)

      _storage.multiInsert(table: Table.account, data: users);

      // Update the language field with the selected value dataL
      _storage.update(
          table: Table.account,
          values: dataL[0],
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);

      _storage.multiInsert(
        table: Table.account2workspace,
        data: users.map(
          (u) => Account2Workspace(
            userId: u.id,
            workspaceId: workspaceId!,
          ),
        ),
      );

      return users;
    }
  }

  Stream<List<Workspace>> fetch({
    String? companyId,
    bool localOnly: false,
  }) async* {
    if (companyId == null) companyId = Globals.instance.companyId;

    var workspaces = await fetchLocal(companyId: companyId!);

    workspaces.sort((w1, w2) => w1.name.compareTo(w2.name));

    yield workspaces;

    if (!Globals.instance.isNetworkConnected || localOnly) return;

    final rworkspaces = await fetchRemote(companyId: companyId);

    rworkspaces.sort((w1, w2) => w1.name.compareTo(w2.name));

    yield rworkspaces;

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
    final localResult = await _storage.select(
      table: Table.workspace,
      where: 'company_id = ?',
      whereArgs: [companyId],
    );

    final workspaces =
        localResult.map((entry) => Workspace.fromJson(json: entry)).toList();

    return workspaces;
  }

  Future<List<Workspace>> fetchRemote({required String companyId}) async {
    final List<dynamic> remoteResult = await _api.get(
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

  Future<Workspace> create({
    String? companyId,
    required String name,
    List<String>? members,
  }) async {
    companyId = companyId ?? Globals.instance.companyId;

    final creationResult = await _api.post(
      endpoint: sprintf(Endpoint.workspaces, [companyId]),
      data: {
        'resource': {
          'name': name,
          'logo': '',
          'default': false,
        }
      },
      key: 'resource',
    );

    final workspace = Workspace.fromJson(json: creationResult, transform: true);

    _storage.insert(table: Table.workspace, data: workspace);

    return workspace;
  }

  Future<List<EmailInvitationResponse>> inviteUser(String companyId, String workspaceId, List<EmailInvitation> invitations) async {
    final List resultList = await _api.post(
      endpoint: sprintf(Endpoint.workspaceInviteEmail, [companyId, workspaceId]),
      key: 'resources',
      data: {'invitations' : invitations.map((e) => e.toJson()).toList()},
    );
    return resultList.map((e) => EmailInvitationResponse.fromJson(e)).toList();
  }

}
