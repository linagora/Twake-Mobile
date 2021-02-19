// import 'dart:convert' show jsonEncode, jsonDecode;
// import 'dart:io' show Platform;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:json_annotation/json_annotation.dart';
// import 'package:package_info/package_info.dart';
// import 'package:twake/services/service_bundle.dart';
//
// part 'configuration_repository.g.dart';
//
// // Index of server ip record in store
// // because it's a global object,
// // it always has only one record in store
// const HOST_KEY = 'host';
//
// @JsonSerializable()
// class ConfigurationRepository extends JsonSerializable {
//   @JsonKey(required: true, name: 'host')
//   String host;
//
//   @JsonKey(ignore: true)
//   static final _storage = Storage();
//   @JsonKey(ignore: true)
//   final logger = Logger();
//
//   ConfigurationRepository() {
//     updateHeaders();
//   }
//   factory ConfigurationRepository.fromJson(Map<String, dynamic> json) =>
//       _$ConfigurationRepositoryFromJson(json);
//
//   static Future<ConfigurationRepository> load() async {
//     var authMap = await _storage.load(
//       type: StorageType.Configuration,
//       fields: _storage.settingsField != null ? [_storage.settingsField] : null,
//       key: HOST_KEY,
//     );
//
//     if (authMap != null) {
//       final authRepository = ConfigurationRepository.fromJson(authMap);
//       return authRepository;
//     }
//     return ConfigurationRepository();
//   }
//
//   Future<AuthResult> authenticate({
//     String username,
//     String password,
//   }) async {
//     try {
//       final response = await _api.post(
//         Endpoint.auth,
//         body: {
//           'username': username,
//           'password': password,
//           'device': platform,
//           'timezoneoffset': '$timeZoneOffset',
//           'fcm_token': fcmToken,
//         },
//         useTokenDio: true,
//       );
//       _updateFromMap(response);
//       logger.d('Successfully authenticated');
//       return AuthResult.Ok;
//     } on ApiError catch (error) {
//       return _handleError(error);
//     } catch (error, stacktrace) {
//       logger.wtf('Something terrible has happened $error\n$stacktrace');
//       throw error;
//     }
//   }
//
//   Future<String> getAuthMode() async {
//     final data = await _api.get(Endpoint.version, useTokenDio: true);
//     if ((data['auth_mode'] as List).contains('console')) {
//       this.authMode = 'CONSOLE';
//       this.twakeConsole = data['auth']['console']['mobile_endpoint_url'];
//     } else {
//       // auth_mode == internal
//       this.authMode = 'INTERNAL';
//     }
//     this.socketIOHost = data['socket_endpoint']['host'];
//     return authMode;
//   }
//
//   Future<bool> setAuthData(Map<String, dynamic> authData) async {
//     try {
//       authData = await initSession(
//           token: authData['token'], username: authData['username']);
//       logger.d('AUTH FROM INIT $authData');
//     } on ApiError catch (error) {
//       logger.e('ERROR AFTER SUCCESSFUL AUTH: ${error.message}');
//       return false;
//     }
//     _updateFromMap(authData);
//     return true;
//   }
//
//   Future<Map<String, dynamic>> initSession(
//       {String username, String token}) async {
//     final body = {
//       "timezoneoffset": timeZoneOffset,
//       "fcm_token": fcmToken,
//       "token": token,
//       "username": username,
//     };
//     print('INIT SESSION: $body');
//     return await _api.post(Endpoint.init, body: body, useTokenDio: true);
//   }
//
//   Future<void> clean() async {
//     logger.d('Requesting storage cleaning');
//     // So that we don't try to validate token if we are not
//     // authenticated
//     _api.prolongToken = null;
//     _api.tokenIsValid = null;
//     accessToken = null;
//     refreshToken = null;
//     await _storage.delete(type: StorageType.Auth, key: AUTH_STORE_KEY);
//   }
//
//   Future<void> fullClean() async {
//     _storage.truncateAll();
//   }
//
//   // Clears up entire database, be carefull!
//   Future<AuthResult> prolongToken() async {
//     logger.d('Prolonging token\nAccess: $accessToken\nRefresh: $refreshToken');
//     try {
//       final response = await _api.post(
//         Endpoint.prolong,
//         body: {
//           'refresh_token': refreshToken,
//           'timezoneoffset': '$timeZoneOffset',
//           'fcm_token': fcmToken,
//         },
//         useTokenDio: true,
//       );
//       _updateFromMap(response);
//       return AuthResult.Ok;
//     } on ApiError catch (error) {
//       logger.e('ERROR PROLONGING TOKEN');
//       return _handleError(error);
//     }
//   }
//
//   Future<void> save() async {
//     await _storage.store(
//       item: {
//         'id': AUTH_STORE_KEY,
//         _storage.settingsField: jsonEncode(this.toJson())
//       },
//       type: StorageType.Auth,
//     );
//   }
//
//   Map<String, dynamic> toJson() => _$AuthRepositoryToJson(this);
//
//   TokenStatus tokenIsValid() {
//     // logger.d('Requesting token validation\n${this.toJson()}');
//     if (this.accessToken == null) {
//       logger.w('Token is empty');
//       return TokenStatus.BothExpired;
//     }
//     final now = DateTime.now();
//     // timestamp is in microseconds, adjusting by multiplying by 1000
//     final accessTokenExpiration =
//     DateTime.fromMillisecondsSinceEpoch(this.accessTokenExpiration * 1000);
//     final refreshTokenExpiration =
//     DateTime.fromMillisecondsSinceEpoch(this.refreshTokenExpiration * 1000);
//     if (now.isAfter(accessTokenExpiration)) {
//       if (now.isAfter(refreshTokenExpiration)) {
//         logger.w('Tokens has expired');
//         clean();
//         return TokenStatus.BothExpired;
//       } else {
//         return TokenStatus.AccessExpired;
//       }
//     }
//     return TokenStatus.Valid;
//   }
//
//   // To update token related fields after instance has been created
//   void updateApiInterceptors() {
//     _api.prolongToken = this.prolongToken;
//     _api.tokenIsValid = this.tokenIsValid;
//   }
//
//   void updateHeaders() {
//     Map<String, String> headers = {
//       'content-type': 'application/json',
//       'Authorization': 'Bearer $accessToken',
//       'Accept-version': apiVersion,
//     };
//     _api.headers = headers;
//   }
//
//   // Set api (dio) interceptors to validate token before requests
//   // and to automatically prolong token on 401
//   AuthResult _handleError(ApiError error) {
//     if (error.type == ApiErrorType.Unauthorized) {
//       return AuthResult.WrongCredentials;
//     } else {
//       logger.e('Authentication error:\n${error.message}\n${error.type}');
//       return AuthResult.NetworkError;
//     }
//   }
//
//   // method used to reinit Api with new headers
//   // specifically new accessToken in the header
//   void _updateFromMap(Map<String, dynamic> map) {
//     this.accessToken = map['token'];
//     this.accessTokenExpiration = map['expiration'].floor();
//     this.refreshToken = map['refresh_token'];
//     this.refreshTokenExpiration = map['refresh_expiration'].floor();
//     save();
//     updateHeaders();
//     updateApiInterceptors();
//   }
// }
//
// enum AuthResult {
//   Ok,
//   WrongCredentials,
//   NetworkError,
// }
