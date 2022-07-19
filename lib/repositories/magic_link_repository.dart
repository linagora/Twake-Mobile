import 'package:twake/models/deeplink/join/workspace_join_request.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/deeplink/manage/workspace_invite_token.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class MagicLinkRepository {
  final _api = ApiService.instance;

  MagicLinkRepository();

  Future<WorkspaceInviteToken> generateToken() async {
    final result = await _api.post(
      endpoint: sprintf(Endpoint.magicLinkTokens, [Globals.instance.companyId, Globals.instance.workspaceId]),
      key: 'resource',
      data: const {},
    );
    return WorkspaceInviteToken.fromJson(result);
  }

  Future<WorkspaceJoinResponse?> joinWorkspace(WorkspaceJoinRequest joinRequest) async {
    final result = await _api.post(
      endpoint: Endpoint.magicLinkJoin,
      data: {
        'join': joinRequest.join,
        'token': joinRequest.token
      },
      key: 'resource',
    );
    return WorkspaceJoinResponse.fromJson(result);
  }

}