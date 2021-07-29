import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:twake/models/globals/globals.dart';

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
    json['language'] = json['preference']['locale'];

    return json;
  }

  static Map<String, dynamic> company({required Map<String, dynamic> json}) {
    json['total_members'] = json['stats']['total_members'];

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

    if (json['user_member'] != null) {
      json['user_last_access'] = json['user_member']['last_access'];

      json['role'] = json['owner'] == json['user_member']['user_id']
          ? 'owner'
          : json['user_member']['type'];
    } else {
      json['role'] =
          json['owner'] == Globals.instance.userId ? 'owner' : 'member';
    }

    return json;
  }

  static Map<String, dynamic> message(
      {required Map<String, dynamic> json, String? channelId}) {
    if (json['stats'] != null && json['stats']['replies'] != null)
      json['responses_count'] = json['stats']['replies'] - 1;
    if (json['last_replies'] != null && channelId != null) {
      final replies = json['last_replies'] as List<dynamic>;
      replies.forEach((r) => r['channel_id'] = channelId);
    }
    json['files'] =
        (json['files'] as List<dynamic>).map((f) => f['id']).toList();

    if (channelId != null) json['channel_id'] = channelId;

    return json;
  }
}
