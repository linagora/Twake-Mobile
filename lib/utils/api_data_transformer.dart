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
}
