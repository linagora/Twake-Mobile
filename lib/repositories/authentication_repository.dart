import 'dart:io';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:twake/models/authentication/authentication.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class AuthenticationRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  bool _validatorRunning = false;

  AuthenticationRepository();

  Future<bool> isAuthenticated() async {
    final result = await _storage.first(table: Table.authentication);
    if (result.isEmpty) return false;
    var authentication = Authentication.fromJson(result);

    switch (hasExpired(authentication)) {
      case Expiration.Valid:
        Globals.instance.tokenSet = authentication.token;
        break;
      case Expiration.Both:
        return false;
      case Expiration.Primary:
        if (!Globals.instance.isNetworkConnected) {
          Globals.instance.tokenSet = authentication.token;
          return true;
        }
        authentication = await prolongAuthentication(authentication);
    }
    return true;
  }

  Future<bool> authenticate({
    required String username,
    required String password,
  }) async {
    dynamic authenticationResult = {};
    try {
      authenticationResult = await _api.post(
        endpoint: Endpoint.authorize,
        data: {
          'username': username,
          'password': password,
          'device': Platform.isAndroid ? 'android' : 'apple',
          'timezoneoffset': tzo,
          'fcm_token': Globals.instance.fcmToken,
        },
      );
    } catch (e) {
      Logger().e('Error occured during authentication:\n$e');
      return false;
    }

    final authentication = Authentication.fromJson(authenticationResult);

    await _storage.truncate(table: Table.authentication);
    _storage.insert(table: Table.authentication, data: authentication);
    Globals.instance.tokenSet = authentication.token;

    return true;
  }

  Future<Authentication> prolongAuthentication(
    Authentication authentication,
  ) async {
    dynamic authenticationResult = {};
    try {
      authenticationResult = await _api.post(
        endpoint: Endpoint.authorizationProlong,
        data: {
          'refresh_token': authentication.refreshToken,
          'fcm_token': Globals.instance.fcmToken,
          'timezoneoffset': tzo,
        },
      );
    } catch (e, ss) {
      final message = 'Error while prolonging token with valid refresh:\n$e';
      Logger().wtf(message);
      Sentry.captureException(Exception(message), stackTrace: ss);
      throw e;
    }

    authentication = Authentication.fromJson(authenticationResult);

    await _storage.truncate(table: Table.authentication);
    _storage.insert(table: Table.authentication, data: authentication);
    Globals.instance.tokenSet = authentication.token;

    return authentication;
  }

  Future<void> logout() async {
    if (Globals.instance.isNetworkConnected) {
      await _api.post(endpoint: Endpoint.logout, data: {
        'fcm_token': Globals.instance.fcmToken,
      });
    }

    Globals.instance.reset();

    await _storage.truncateAll();
  }

  Expiration hasExpired(Authentication authentication) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expired = authentication.expiration > now;
    final refreshExpired = authentication.refreshExpiration > now;

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

    final now = DateTime.now().millisecondsSinceEpoch;
    final needToProlong = authentication.expiration - now <
        10 * 60 * 1000; // less than 10 minutes to expiration
    if (needToProlong) {
      authentication = await prolongAuthentication(authentication);
    }
    Future.delayed(Duration(minutes: 5), () => _tokenValidityCheck());
  }

  int get tzo => -DateTime.now().timeZoneOffset.inMinutes;
}

enum Expiration {
  Valid,
  Primary,
  Both,
}
