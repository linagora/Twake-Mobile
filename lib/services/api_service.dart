import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class ApiService {
  static late ApiService _service;
  late final Dio _dio;
  static const _PROXY_PREFIX = '/internal/mobile';

  factory ApiService({required bool reset}) {
    if (reset) {
      _service = ApiService._();
    }
    return _service;
  }

  static ApiService get instance => _service;

  ApiService._() {
    _dio = Dio(BaseOptions(
      contentType: 'application/json',
      connectTimeout: 60 * 1000, // 60 seconds to connect
      receiveTimeout: 30 * 1000, // 30 seconds to receive data
    ));

    void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
      options.baseUrl = Globals.instance.host + _PROXY_PREFIX;
      if (Endpoint.isPublic(options.path)) {
        handler.next(options);
        return;
      }
      final token = Globals.instance.token;
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }

    void onError(DioError error, ErrorInterceptorHandler handler) {
      Logger().e('Request error:\n$error'
          '\nHEADERS: ${error.requestOptions.headers}'
          '\nPATH: ${error.requestOptions.uri.path}'
          '\nRESPONSE: ${error.response?.data}'
          '\nQUERYPARAMS: ${error.requestOptions.queryParameters}'
          '\nREQUEST PAYLOAD: ${error.requestOptions.data}');
      switch (error.type) {
        case DioErrorType.cancel:
          // just successfully resolve request if user cancelled it
          handler.resolve(Response(
            data: const {},
            requestOptions: error.requestOptions,
          ));
          break;
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
          // log timeout event to sentry, for further investigation
          Sentry.captureMessage(
            'Request to API timed out\n'
            'method: ${error.requestOptions.method}\n'
            'endpoint: ${error.requestOptions.path}\n'
            'params: ${error.requestOptions.queryParameters}\n'
            'body: ${error.requestOptions.data}',
          );
          handler.reject(error);
          break;
        case DioErrorType.response:
          final sc = error.response?.statusCode;
          if (sc! >= 500) {
            // send all server side error to sentry, for further investigation
            Sentry.captureException(
              error,
              stackTrace: 'method: ${error.requestOptions.method}\n'
                  'endpoint: ${error.requestOptions.path}\n'
                  'params: ${error.requestOptions.queryParameters}\n'
                  'body: ${error.requestOptions.data}',
            );
          }
          handler.reject(error);
          break;
        default:
          handler.reject(error);
      }
    }

    final interceptor = InterceptorsWrapper(
      onRequest: onRequest,
      onError: onError,
    );
    this._dio.interceptors.add(interceptor);
  }

  Future<dynamic> get({
    required String endpoint,
    Map<String, dynamic> queryParameters: const {},
    CancelToken? cancelToken,
  }) async {
    final r = await this._dio.get(
          endpoint,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
        );
    return r.data;
  }

  Future<dynamic> post({
    required String endpoint,
    required dynamic data,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final r = await this._dio.post(
          endpoint,
          data: data,
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
        );
    return r.data;
  }

  Future<dynamic> put({
    required String endpoint,
    required dynamic data,
    CancelToken? cancelToken,
  }) async {
    final r = await this._dio.put(
          endpoint,
          data: data,
          cancelToken: cancelToken,
        );
    return r.data;
  }

  Future<dynamic> patch({
    required String endpoint,
    required dynamic data,
    CancelToken? cancelToken,
  }) async {
    final r = await this._dio.patch(
          endpoint,
          data: data,
          cancelToken: cancelToken,
        );
    return r.data;
  }

  Future<dynamic> delete({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    final r = await this._dio.delete(
          endpoint,
          data: data,
        );
    return r.data;
  }
}
