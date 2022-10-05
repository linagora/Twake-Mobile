import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';

class ApiDataTransformer {
  static Map<String, dynamic> token({
    required Map<String, dynamic> payload,
    AuthorizationTokenResponse? tokenResponse,
  }) {
    final accessToken = payload['access_token'];
    if (accessToken == null) throw 'Invalid payload for access token';

    return {
      'token': accessToken['value'],
      'refresh_token': accessToken['refresh'],
      'expiration': accessToken['expiration'],
      'refresh_expiration': accessToken['refresh_expiration'],
      'console_token': tokenResponse?.accessToken,
      'id_token': tokenResponse?.idToken,
      'console_refresh': tokenResponse?.refreshToken,
      'console_expiration': tokenResponse
              ?.accessTokenExpirationDateTime!.millisecondsSinceEpoch ??
          0 ~/ 1000
    };
  }

  static Map<String, dynamic> account({required Map<String, dynamic> json}) {
    if (json['preferences'] != null) {
      json['language'] = json['preferences']['locale'];
      if (json['preferences']['recent_workspaces'] != null) {
        json['workspace_id'] =
            json['preferences']['recent_workspaces'][0]['workspace_id'];
        json['company_id'] =
            json['preferences']['recent_workspaces'][0]['company_id'];
      }
    }
    if (json['is_verified'] != null) {
      json['is_verified'] = json['is_verified'] ? 1 : 0;
    }
    if (json['deleted'] != null) {
      json['deleted'] = json['deleted'] ? 1 : 0;
    }

    return json;
  }

  static Map<String, dynamic> company({required Map<String, dynamic> json}) {
    json['total_members'] = json['stats']['total_members'];
    json['role'] = (json['role'] ?? '').isNotEmpty ? json['role'] : 'member';

    return json;
  }

  static Map<String, dynamic> workspace({required Map<String, dynamic> json}) {
    json['total_members'] = json['stats']['total_members'];

    return json;
  }

  static Map<String, dynamic> channel({required Map<String, dynamic> json}) {
    if (json['last_message'] != null &&
        (json['last_message'] as Map<String, dynamic>).isEmpty) {
      json['last_message'] = null;
    }
    if (json['members'] != null) {
      json['members'] = json['workspace_id'] == 'direct' ? json['members'] : [];
    }
    if (json['user_member'] != null) {
      json['user_last_access'] = json['user_member']['last_access'];
    }
    json['role'] =
        json['owner'] == Globals.instance.userId ? 'owner' : 'member';

    if (json['last_activity'] == null) json['last_activity'] = 0;

    if (json['workspace_id'] == 'direct' && json['users'] != null) {
      final users = json['users'] as List;

      if (users.length > 1)
        users.retainWhere((u) => u['id'] != Globals.instance.userId);

      json['name'] = users.map((u) {
        final String name = u['first_name'] == null
            ? u['username']
            : (u['first_name'] as String).isNotEmpty
                ? u['first_name']
                : u['username'];
        return name;
      }).join(', ');

      json['icon'] = users.map((u) {
        return u['picture'] ?? '';
      }).join(',');
    }

    return json;
  }

  static Map<String, dynamic> message({
    required Map<String, dynamic> json,
    String? channelId,
  }) {
    if (json['stats'] != null && json['stats']['replies'] != null)
      json['responses_count'] = json['stats']['replies'] - 1;
    if (json['files'] != null) {
      json['files'] = (json['files'] as List<dynamic>).map((f) {
        try {
          final externalFileId = f['metadata']['external_id']['id'];
          return externalFileId;
        } catch (e) {
          return '';
        }
      }).toList();
    } else {
      json['files'] = <String>[];
    }
    if (json['application'] != null) {
      final app = json['application']['identity'];
      json['username'] = app['name'];
      json['picture'] = app['icon'];
    } else if (json.containsKey('users') &&
        (json['users'] as List<dynamic>).isNotEmpty) {
      final user = (json['users'] as List<dynamic>).first;

      json['username'] = user['username'];
      json['first_name'] = user['first_name'];
      json['last_name'] = user['last_name'];
      json['picture'] = user['picture'];
    }

    json['channel_id'] = channelId;

    return json;
  }

  static Map<String, dynamic> apiMessage({
    required Message message,
    bool removeIds: true,
  }) {
    final json = message.toJson(stringify: false);
    if (removeIds) {
      json.remove('id');
      json.remove('thread_id');
    }
    json['type'] = 'message';
    json['subtype'] = null;
    json['context'] = const {};

    return json;
  }

  static List<Map<String, dynamic>> badges({required List<dynamic> list}) {
    final badgeCollection = <String, Map<String, dynamic>>{};

    for (final i in list) {
      final String companyId = i['company_id'];
      final String workspaceId = i['workspace_id'];
      final String channelId = i['channel_id'];

      if (badgeCollection.containsKey(companyId)) {
        badgeCollection[companyId]!['count'] += 1;
      } else {
        badgeCollection[companyId] = {
          'type': 'company',
          'id': companyId,
          'count': 1,
        };
      }
      if (badgeCollection.containsKey(workspaceId)) {
        badgeCollection[workspaceId]!['count'] += 1;
      } else {
        badgeCollection[workspaceId] = {
          'type': 'workspace',
          'id': workspaceId,
          'count': 1,
        };
      }
      if (badgeCollection.containsKey(channelId)) {
        badgeCollection[channelId]!['count'] += 1;
      } else {
        badgeCollection[channelId] = {
          'type': 'channel',
          'id': channelId,
          'count': 1,
        };
      }
    }

    return badgeCollection.values.toList();
  }

  static Map<String, dynamic> messageFile(
      {required Map<String, dynamic> json}) {
    json['context']['file_id'] = json['context']['file_id'] == null
        ? ""
        : json['context']['file_id'].runtimeType == String
            ? json['context']['file_id']
            : json['context']['file_id']['id'];
    json['metadata']['external_id'] = json['metadata']['external_id'] == null
        ? ""
        : json['metadata']['external_id'].runtimeType == String
            ? json['metadata']['external_id']
            : json['metadata']['external_id']['id'];
    return json;
  }
}
