import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

const _CONNECT_TIMEOUT = 50000;
const String _HOST = 'https://mobile.api.twake.app';
const _RECEIVE_TIMEOUT = 7000;
const _SEND_TIMEOUT = 5000;

class Api {
  // singleton Api class instance
  static Api _api;
  // required by twake api
  final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
  // logging utility
  final logger = Logger();
  // callback function to auto prolong token, if access token has expired
  Future<Map<String, String>> Function() _prolongToken;
  // callback function to validate token
  bool Function() _tokenIsValid;
  Dio dio;

  factory Api({Map<String, String> headers}) {
    // if the headers are present, e.g. token has changed,
    // reinitialize Dio
    if (_api == null || headers != null) {
      _api = Api._(headers);
    }
    return _api;
  }

  // internal private constructor (singleton pattern)
  Api._(Map<String, String> headers) {
    dio = Dio(
      BaseOptions(
          connectTimeout: _CONNECT_TIMEOUT,
          receiveTimeout: _RECEIVE_TIMEOUT,
          sendTimeout: _SEND_TIMEOUT,
          headers: headers),
    );
  }

  // if referesh has changed, then we reset dio interceptor to account for this
  set prolongToken(value) {
    _prolongToken = value;
    _addDioInterceptors();
  }

  set tokenIsValid(value) {
    _tokenIsValid = value;
    _addDioInterceptors();
  }

  Future<dynamic> delete(
    String method, {
    Map<String, String> body,
  }) async {
    final url = _HOST + method;
    final response = await dio.delete(url, data: body);
    return response.data;
  }

  Future<dynamic> get(
    String method, {
    Map<String, dynamic> params: const {},
  }) async {
    final url = _HOST + method;
    final response = await dio.get(url, queryParameters: params);
    return response.data;
  }

  Future<dynamic> patch(
    String method, {
    Map<String, String> body,
  }) async {
    final url = _HOST + method;
    final response = await dio.patch(url, data: body);
    return response.data;
  }

  Future<dynamic> post(
    String method, {
    Map<String, String> body,
  }) async {
    final url = _HOST + method;
    final response = await dio.post(url, data: body);
    return response.data;
  }

  // helper method to add on request and on error interceptors to Dio
  void _addDioInterceptors() {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (_) {
          if (!_tokenIsValid()) {
            throw DioError(
              type: DioErrorType.CANCEL,
              error: 'Token has expired',
            );
          }
        },
        onError: (DioError error) {
          if (error.response.statusCode == 401 && _prolongToken != null) {
            logger.e('Token has expired prematuraly, prolonging...');
            _prolongToken();
          }
          return error;
        },
      ),
    );
  }
}
