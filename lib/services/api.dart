import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

// const String _HOST = 'mobile.api.twake.app';
// const String _SHOST = 'https://mobile.api.twake.app';
// const String _SCHEME = 'https';
const _RECEIVE_TIMEOUT = 7000;
const _SEND_TIMEOUT = 5000;
const _CONNECT_TIMEOUT = 50000;

class Api {
  // singleton Api class instance
  static Api _api;
  // Server address
  static String host;
  // logging utility
  static final logger = Logger();
  // callback function to auto prolong token, if access token has expired
  Future<dynamic> Function() _prolongToken;
  // callback function to validate token
  TokenStatus Function() _tokenIsValid;
  // callback to reset authentication if for e.g. token has expired
  void Function() _resetAuthentication;

  bool hasConnection = false;

  Dio dio;
  final Dio tokenDio = Dio();

  factory Api({Map<String, String> headers, String ip}) {
    // if the headers are present, e.g. token has changed,
    // reinitialize Dio
    if (_api == null) {
      _api = Api._();
    }
    if (ip != null) {
      host = ip;
    }
    return _api;
  }

  // internal private constructor (singleton pattern)
  Api._() {
    dio = Dio(
      BaseOptions(
        connectTimeout: _CONNECT_TIMEOUT,
        receiveTimeout: _RECEIVE_TIMEOUT,
        sendTimeout: _SEND_TIMEOUT,
      ),
    );
    _addDioInterceptors();
  }

  set headers(Map<String, String> value) {
    dio.options.headers = value;
    tokenDio.options.headers = Map.from(value)..remove('Authorization');
  }

  // if refresh has changed, then we reset dio interceptor to account for this
  set prolongToken(value) {
    _prolongToken = value;
  }

  set tokenIsValid(value) {
    _tokenIsValid = value;
  }

  set resetAuthentication(value) {
    _resetAuthentication = value;
  }

  void checkConnection() {
    // logger.d('HAS CONNECTION: $hasConnection');
    if (!hasConnection)
      throw ApiError(
        message: 'No internet connection',
        type: ApiErrorType.NoInternetAccess,
      );
  }

  Future<dynamic> delete(
    String method, {
    Map<String, dynamic> body,
  }) async {
    checkConnection();
    // final url = _SHOST + method;
    final url = host + method;
    try {
      final response = await dio.delete(url, data: body);
      // logger.d('METHOD: $url');
      // logger.d('GET HEADERS: ${dio.options.headers}');
      // logger.d('DELETE REQUEST BODY: $body');
      // logger.d('DELETE RESPONSE: ${response.data}');
      return response.data;
    } catch (e) {
      throw ApiError.fromDioError(e);
    }
  }

  Future<dynamic> get(
    String method, {
    Map<String, dynamic> params: const {},
    bool useTokenDio: false,
  }) async {
    checkConnection();

    // Extract scheme and host by splitting the url
    var split = Api.host.split('://');
    assert(split.length == 2, 'PROXY URL DOES NOT CONTAIN URI SCHEME OR HOST');
    final scheme = split[0];
    var host = split[1];
    split = host.split(':');
    var port;
    if (split.length == 2) {
      host = split[0];
      port = int.parse(split[1]);
    }

    // logger.d('host: $host\nport: $port\n$scheme');
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: method,
      queryParameters: params,
    );
    try {
      final s = Stopwatch();
      s.start();
      final response = await dio.getUri(uri);
      s.stop();
      // logger.d('GET HEADERS: ${dio.options.headers}');
      // logger.d('PARAMS: $params');
      // logger.d(
      // 'METHOD: ${uri.toString()}\nTOOK: ${s.elapsedMilliseconds / 1000} seconds');
      // logger.d('GET RESPONSE: ${response.data}');
      return response.data;
    } catch (e) {
      throw ApiError.fromDioError(e);
    }
  }

  Future<dynamic> patch(
    String method, {
    Map<String, dynamic> body,
  }) async {
    checkConnection();
    // final url = _SHOST + method;
    final url = host + method;

    try {
      final response = await dio.patch(url, data: body);
      return response.data;
    } catch (e) {
      throw ApiError.fromDioError(e);
    }
  }

  Future<dynamic> put(
    String method, {
    Map<String, dynamic> body,
  }) async {
    checkConnection();
    // final url = _SHOST + method;
    final url = host + method;

    try {
      final response = await dio.put(url, data: body);
      return response.data;
    } catch (e) {
      throw ApiError.fromDioError(e);
    }
  }

  Future<dynamic> post(
    String method, {
    Map<String, dynamic> body,
    bool useTokenDio = false,
  }) async {
    checkConnection();
    // final url = _SHOST + method;
    final url = host + method;

    try {
      // logger.d('METHOD: $url\nHEADERS: ${dio.options.headers}');
      // logger.d('BODY: ${jsonEncode(body)}');
      final response =
          await (useTokenDio ? tokenDio : dio).post(url, data: body);
      // logger.d('POST RESPONSE ${response.data}');
      return response.data;
    } catch (e) {
      logger.wtf(e);
      throw ApiError.fromDioError(e);
    }
  }

  Future<bool> autoProlongToken() async {
    if (_tokenIsValid != null) {
      switch (_tokenIsValid()) {
        case TokenStatus.Valid:
          break;
        case TokenStatus.AccessExpired:
          await _prolongToken();
          break;
        case TokenStatus.BothExpired:
          _resetAuthentication();
          return false;
      }
    }
    return true;
  }

  // helper method to add on request and on error interceptors to Dio
  void _addDioInterceptors() {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        // token validation causes infinite loop
        onRequest: (options) async {
          if (!(await autoProlongToken())) {
            return dio.reject('Both tokens have expired');
          }
          // print('REQUEST HEADERS: ${options.headers}\n'
          // 'DIO HEADERS: ${dio.options.headers}');
          options.headers['Authorization'] =
              dio.options.headers['Authorization'];
        },
        onError: (DioError error) async {
          // Due to the bugs in JWT handling from twake api side,
          // we randomly get token expirations, so if we have a
          // refresh token, we automatically use it to get a new token
          logger.e('Error during network request!' +
              '\nMethod: ${error.request.method}' +
              '\nPATH: ${error.request.path}' +
              '\nHeaders: ${error.request.headers}' +
              '\nResponse: ${error.response.data}' +
              '\nBODY: ${jsonEncode(error.request.data)}' +
              '\nQUERY: ${error.request.queryParameters}');
          if (error.response.statusCode == 401 && _prolongToken != null) {
            logger.e('Token has expired prematuraly, prolonging...');
            await _prolongToken();
          } else {
            logger.e('status code: ${error.response.statusCode}');
            return error;
          }
        },
      ),
    );
  }
}

enum ApiErrorType {
  NoInternetAccess,
  TokenExpired,
  Unauthorized,
  BadRequest,
  ServerError,
  NotFound,
  Unknown
}

class ApiError implements Exception {
  final String message;
  final ApiErrorType type;
  const ApiError({this.message: '', this.type: ApiErrorType.Unknown});

  factory ApiError.fromDioError(DioError error) {
    var apiErrorType = ApiErrorType.Unknown;
    if (error.response.statusCode == 500) {
      apiErrorType = ApiErrorType.ServerError;
    } else if (const [401, 403].contains(error.response.statusCode)) {
      apiErrorType = ApiErrorType.Unauthorized;
    } else if (error.response.statusCode == 400) {
      apiErrorType = ApiErrorType.BadRequest;
    } else if (error.response.statusCode == 404) {
      apiErrorType = ApiErrorType.NotFound;
    } else {
      throw error;
    }

    return ApiError(
      message: '${error.response.data}',
      type: apiErrorType,
    );
  }
}

enum TokenStatus {
  AccessExpired,
  BothExpired,
  Valid,
}
