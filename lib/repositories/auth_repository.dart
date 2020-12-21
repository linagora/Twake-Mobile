import 'dart:io' show Platform;

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/services/service_bundle.dart';

part 'auth_repository.g.dart';

// Index of auth record in store
// because it's a global object,
// it always has only one record in store
const _AUTH_STORE_INDEX = 0;

@JsonSerializable()
class AuthRepository extends JsonSerializable {
  @JsonKey(required: true, name: 'token')
  String accessToken;

  @JsonKey(required: true, name: 'refresh_token')
  String refreshToken;

  @JsonKey(required: true, name: 'expiration')
  int accessTokenExpiration;

  @JsonKey(required: true, name: 'refresh_expiration')
  int refreshTokenExpiration;

  // required by twake api
  @JsonKey(ignore: true)
  final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;

  @JsonKey(ignore: true)
  final _storage = Storage();
  @JsonKey(ignore: true)
  var _api = Api();
  @JsonKey(ignore: true)
  final _logger = Logger();
  @JsonKey(ignore: true)
  String fcmToken;

  String get platform => Platform.isAndroid ? 'android' : 'apple';
  AuthRepository([this.fcmToken]);

  Future<bool> tokenIsValid() async {
    _logger.d('Requesting validation');
    if (this.accessToken == null) {
      _logger.w('Token is empty');
      return false;
    }
    final now = DateTime.now();
    // timestamp is in microseconds, adjusting by multiplying by 1000
    final accessTokenExpiration =
        DateTime.fromMillisecondsSinceEpoch(this.accessTokenExpiration * 1000);
    final refreshTokenExpiration =
        DateTime.fromMillisecondsSinceEpoch(this.accessTokenExpiration * 1000);
    if (now.isAfter(accessTokenExpiration)) {
      if (now.isAfter(refreshTokenExpiration)) {
        _logger.w('Tokens has expired');
        await clean();
        return false;
      } else {
        final result = await prolongToken();
        if (result == AuthResult.Ok) {
          return true;
        }
        await clean();
        return false;
      }
    }
    return true;
  }

  Future<AuthResult> authenticate({
    String username,
    String password,
  }) async {
    try {
      final response = await _api.post(Endpoint.auth, body: {
        'username': username,
        'password': password,
        'device': platform,
        'timezoneoffset': '$timeZoneOffset',
        'fcm_token': fcmToken,
      });
      _updateFromMap(response);
      _logger.d('Successfully authenticated');
      return AuthResult.Ok;
    } on ApiError catch (error) {
      return _handleError(error);
    } catch (error, stacktrace) {
      _logger.wtf('Something terrible has happened $error\n$stacktrace');
      throw error;
    }
  }

  Future<AuthResult> prolongToken() async {
    try {
      final response = await _api.post(Endpoint.prolong, body: {
        'token': refreshToken,
        'timezoneoffset': '$timeZoneOffset',
        'fcm_token': fcmToken,
      });
      _updateFromMap(response);
      return AuthResult.Ok;
    } on ApiError catch (error) {
      return _handleError(error);
    }
  }

  Future<void> save() async {
    await _storage.store(
      item: this,
      type: StorageType.Auth,
      key: _AUTH_STORE_INDEX,
    );
  }

  Future<void> clean() async {
    // So that we don't try to validate token if we are not
    // authenticated
    _logger.d('Requesting storage cleaning');
    _api.prolongToken = null;
    _api.tokenIsValid = null;
    accessToken = null;
    refreshToken = null;
    await _storage.clean(type: StorageType.Auth, key: _AUTH_STORE_INDEX);
  }

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory AuthRepository.fromJson(Map<String, dynamic> json) =>
      // After getting instance of auth from store, we should make sure
      // that api has valid callbacks for validation and
      // prolonging token + set up to date headers
      _$AuthRepositoryFromJson(json)
        ..updateHeaders()
        ..updateApiInterceptors();

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$AuthRepositoryToJson(this);

  // To update token related fields after instance has been created
  void _updateFromMap(Map<String, dynamic> map) {
    this.accessToken = map['token'];
    this.accessTokenExpiration = map['expiration'];
    this.refreshToken = map['refresh_token'];
    this.refreshTokenExpiration = map['refresh_expiration'];
    save();
    updateHeaders();
    updateApiInterceptors();
  }

  AuthResult _handleError(ApiError error) {
    if (error.type == ApiErrorType.Unauthorized) {
      return AuthResult.WrongCredentials;
    } else {
      _logger.e('Authentication error:\n${error.message}\n${error.type}');
      return AuthResult.NetworkError;
    }
  }

  // Set api (dio) interceptors to validate token before requests
  // and to automatically prolong token on 401
  void updateApiInterceptors() {
    _api.prolongToken = this.prolongToken;
    _api.tokenIsValid = this.tokenIsValid;
  }

  // method used to reinit Api with new headers
  // specifically new accessToken in the header
  void updateHeaders() {
    Map<String, String> headers = {
      'content-type': 'application/json',
      'authorization': 'Bearer $accessToken',
    };
    _api = Api(headers: headers);
  }
}

enum AuthResult {
  Ok,
  WrongCredentials,
  NetworkError,
}
