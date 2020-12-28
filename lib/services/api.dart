import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

const _CONNECT_TIMEOUT = 50000;
const String _HOST = 'mobile.api.twake.app';
const String _SHOST = 'https://mobile.api.twake.app';
const String _SCHEME = 'https';
const _RECEIVE_TIMEOUT = 7000;
const _SEND_TIMEOUT = 5000;

class Api {
  // singleton Api class instance
  static Api _api;
  // logging utility
  static final logger = Logger();
  // callback function to auto prolong token, if access token has expired
  Future<dynamic> Function() _prolongToken;
  // callback function to validate token
  TokenStatus Function() _tokenIsValid;
  // callback to reset authentication if for e.g. token has expired
  void Function() _resetAuthentication;

  Dio dio;
  final Dio tokenDio = Dio();

  factory Api({Map<String, String> headers}) {
    // if the headers are present, e.g. token has changed,
    // reinitialize Dio
    if (_api == null || headers != null) {
      bool notNull = _api != null;
      // save and restore the callbacks
      var tiv;
      var pt;
      var ra;
      if (notNull) {
        tiv = _api._tokenIsValid;
        pt = _api._prolongToken;
        ra = _api._resetAuthentication;
      }
      _api = Api._(headers);
      if (notNull) {
        _api._tokenIsValid = tiv;
        _api._prolongToken = pt;
        _api._resetAuthentication = ra;
      }
    }
    return _api;
  }

  // internal private constructor (singleton pattern)
  Api._(Map<String, String> headers) {
    tokenDio.options.headers = headers;
    dio = Dio(
      BaseOptions(
          connectTimeout: _CONNECT_TIMEOUT,
          receiveTimeout: _RECEIVE_TIMEOUT,
          sendTimeout: _SEND_TIMEOUT,
          headers: headers),
    );
    _addDioInterceptors();
  }

  // if referesh has changed, then we reset dio interceptor to account for this
  set prolongToken(value) {
    _prolongToken = value;
  }

  set tokenIsValid(value) {
    _tokenIsValid = value;
  }

  set resetAuthentication(value) {
    _resetAuthentication = value;
  }

  Future<dynamic> delete(
    String method, {
    Map<String, String> body,
  }) async {
    final url = _SHOST + method;
    final response = await dio.delete(url, data: body);
    return response.data;
  }

  Future<dynamic> get(
    String method, {
    Map<String, dynamic> params: const {},
  }) async {
    final uri = Uri(
      scheme: _SCHEME,
      host: _HOST,
      path: method,
      queryParameters: params,
    );
    final response = await dio.getUri(uri);
    return response.data;
  }

  Future<dynamic> patch(
    String method, {
    Map<String, String> body,
  }) async {
    final url = _SHOST + method;
    final response = await dio.patch(url, data: body);
    return response.data;
  }

  Future<dynamic> post(
    String method, {
    Map<String, String> body,
    bool useTokenDio = false,
  }) async {
    final url = _SHOST + method;
    final response = await (useTokenDio ? tokenDio : dio).post(url, data: body);
    return response.data;
  }

  // helper method to add on request and on error interceptors to Dio
  void _addDioInterceptors() {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        // token validation causes infinite loop
        onRequest: (options) async {
          logger.d('URI: ${options.uri}\nQP: ${options.queryParameters}');
          if (_tokenIsValid != null) {
            switch (_tokenIsValid()) {
              case TokenStatus.Valid:
                break;
              case TokenStatus.AccessExpired:
                await _prolongToken();
                break;
              case TokenStatus.BothExpired:
                _resetAuthentication();
                return dio.reject('Both tokens have expired');
            }
          }
        },
        onError: (DioError error) {
          // Due to the bugs in JWT handling from twake api side,
          // we randomly get token expirations, so if we have a
          // referesh token, we automatically use it to get a new token
          logger.e('Error during network request\n${error.response.data}');
          if (error.response.statusCode == 401 && _prolongToken != null) {
            logger.e('Token has expired prematuraly, prolonging...');
            _prolongToken();
          }
          return ApiError.fromDioError(error);
        },
      ),
    );
  }
}

enum ApiErrorType {
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
    } else if (error.response.statusCode == 401) {
      apiErrorType = ApiErrorType.Unauthorized;
    } else if (error.response.statusCode == 400) {
      apiErrorType = ApiErrorType.BadRequest;
    } else if (error.response.statusCode == 404) {
      apiErrorType = ApiErrorType.NotFound;
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
