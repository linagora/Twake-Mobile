import 'package:flutter_appauth/flutter_appauth.dart';

class ApiDataTransformer {
  static Map<String, dynamic> token({
    required Map<String, dynamic> payload,
    required AuthorizationTokenResponse tokenResponse,
  }) {
    final accessToken = payload['access_token'];
    if (accessToken == null) throw 'Invalid payload for access token';

    return {
      'token': accessToken['value'],
      'refresh_token': accessToken['refresh'],
      'expiration': accessToken['expiration'],
      'refresh_expiration': accessToken['refresh_expiration'],
      'console_token': tokenResponse.accessToken,
      'id_token': tokenResponse.idToken,
      'console_refresh': tokenResponse.refreshToken,
      'console_expiration':
          tokenResponse.accessTokenExpirationDateTime!.millisecondsSinceEpoch ~/
              1000
    };
  }

  static Map<String, dynamic> account({required Map<String, dynamic> json}) {
    json['language'] = json['preference']['local'];

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
}

// {
//   "id": "uuid",
//   "company_id": "string", //Related to console "code"
//   "name": "string",
//   "logo": "string",
//
//   "default": boolean,
//   "archived": boolean,
//
//   "stats": {
//     "created_at": timestamp,
//     "total_members": number,
//     //Will be completed with Twake specific stats
//   },
//
//   //If requested as a user
//   "role": "admin" | "member",
// }
