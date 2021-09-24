import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:twake/models/authentication/authentication.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:twake/utils/api_data_transformer.dart';

class AuthenticationRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  final _appAuth = FlutterAppAuth();
  bool _validatorRunning = false;
  // for logout
  String idToken = '';

  AuthenticationRepository();

  Future<bool> isAuthenticated() async {
    final result = await _storage.first(table: Table.authentication);
    if (result.isEmpty) return false;
    var authentication = Authentication.fromJson(result);
    idToken = authentication.idToken;

    switch (hasExpired(authentication)) {
      case Expiration.Valid:
        Globals.instance.tokenSet = authentication.token;
        break;
      case Expiration.Both:
        logout();
        return false;
      case Expiration.Primary:
        if (!Globals.instance.isNetworkConnected) {
          Globals.instance.tokenSet = authentication.token;
          return true;
        }
        authentication = await prolongAuthentication(authentication);
        SocketIOService.instance.connect();
        idToken = authentication.idToken;
    }

    return true;
  }

  Future<bool> webviewAuthenticate() async {
    AuthorizationTokenResponse? tokenResponse;

    while (true) {
      try {
        tokenResponse = await _appAuth.authorizeAndExchangeCode(
          AuthorizationTokenRequest(
            'twakemobile', // Globals.instance.clientId!,
            'twakemobile.com://oauthredirect',
            discoveryUrl:
                '${Globals.instance.oidcAuthority}/.well-known/openid-configuration',
            scopes: ['openid', 'profile', 'email', 'offline_access'],
            preferEphemeralSession: true,
            promptValues: ['consent'],
            responseMode: 'query',
          ),
        );
      } catch (e, ss) {
        Logger().wtf('Error authenticating via console\n$e\n$ss');
        return false;
      }
      if (tokenResponse == null) {
        Logger().w('Token is null, retrying auth');
        continue;
      } else {
        break;
      }
    }
    final authenticationResult = await _api.post(
      endpoint: Endpoint.login,
      data: {'remote_access_token': tokenResponse.accessToken},
    );

    final authentication = Authentication.fromJson(ApiDataTransformer.token(
      payload: authenticationResult,
      tokenResponse: tokenResponse,
    ));
    this.idToken = authentication.idToken;

    _storage.cleanInsert(table: Table.authentication, data: authentication);
    Globals.instance.tokenSet = authentication.token;

    registerDevice();

    return true;
  }

  Future<Authentication> prolongAuthentication(
    Authentication authentication,
  ) async {
    Map<String, dynamic> authenticationResult = {};

    Globals.instance.tokenSet = authentication.refreshToken;

    try {
      authenticationResult = await _api.post(
        endpoint: Endpoint.authorizationProlong,
        data: const {},
      );
    } catch (e, ss) {
      final message = 'Error while prolonging token with valid refresh:\n$e';
      Logger().wtf(message);
      Sentry.captureException(Exception(message), stackTrace: ss);
      throw e;
    }

    final freshAuthentication = Authentication.complementWithConsole(
      json: ApiDataTransformer.token(payload: authenticationResult),
      other: authentication,
    );

    this.idToken = freshAuthentication.idToken;

    _storage.cleanInsert(
      table: Table.authentication,
      data: freshAuthentication,
    );

    Globals.instance.tokenSet = freshAuthentication.token;

    registerDevice();

    return freshAuthentication;
  }

  Future<void> logout() async {
    if (Globals.instance.isNetworkConnected) {
      _api.delete(
        endpoint: Endpoint.device + '/${Globals.instance.fcmToken}',
        data: const {},
      );
    } else {
      return;
    }

    await _appAuth.endSession(
      EndSessionRequest(
        postLogoutRedirectUrl: 'twakemobile.com://oauthredirect',
        idTokenHint: this.idToken,
        discoveryUrl:
            '${Globals.instance.oidcAuthority}/.well-known/openid-configuration',
      ),
    );
    Logger().w('session ended');
//
    Globals.instance.reset();

    await _storage.truncateAll();
  }

  Expiration hasExpired(Authentication authentication) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expired = authentication.expiration < now;
    final refreshExpired = authentication.refreshExpiration < now;

    if (refreshExpired) return Expiration.Both;
    if (expired) return Expiration.Primary;
    return Expiration.Valid;
  }

  void startTokenValidator() async {
    if (_validatorRunning) return;

    _tokenValidityCheck();
  }

  Future<void> _tokenValidityCheck() async {
    if (!Globals.instance.isNetworkConnected) {
      _validatorRunning = false;
      return;
    }
    final result = await _storage.first(table: Table.authentication);
    if (result.isEmpty) {
      _validatorRunning = false;
      return;
    }

    var authentication = Authentication.fromJson(result);

    // Logger().v(
    // 'Token validity check, expires at: '
    // '${DateTime.fromMillisecondsSinceEpoch(authentication.expiration * 1000)}',
    // );

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final needToProlong = authentication.expiration - now <
        10 * 60; // less than 10 minutes to expiration
    if (needToProlong) {
      authentication = await prolongAuthentication(authentication);
    }
    Future.delayed(Duration(seconds: 120), () => _tokenValidityCheck());
  }

  Future<void> registerDevice() async {
    if (!Globals.instance.isNetworkConnected) return;
    if (Globals.instance.token == null) return;

    final data = {
      'resource': {
        'type': 'FCM',
        'value': Globals.instance.fcmToken,
        'version': Globals.version,
      }
    };
    await _api.post(endpoint: Endpoint.device, data: data);
  }

  int get tzo => -DateTime.now().timeZoneOffset.inMinutes;
}

enum Expiration {
  Valid,
  Primary,
  Both,
}
