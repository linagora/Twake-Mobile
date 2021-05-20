import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class ApiService {
  static ApiService? _service;
  late final Dio _dio;

  ApiService? get instance {
    if (_service == null) {
      _service = ApiService._();
    }
    return _service;
  }

  ApiService._() {
    this._dio = Dio(BaseOptions(
      contentType: 'application/json',
      connectTimeout: 15 * 1000, // 15 seconds to connect
      receiveTimeout: 30 * 1000, // 30 seconds to recieve data
    ));

    void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
      options.baseUrl = Globals.instance.host;
      if (!Endpoint.isPublic(options.path)) return;
      final token = Globals.instance.token;
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }

    void onError(DioError error, ErrorInterceptorHandler handler) {
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
          // log timeout event to sentry, for further investigaion
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
            // send all server side error to sentry, for further investigaion
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
    return r;
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
    return r;
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
    return r;
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
    return r;
  }

  Future<dynamic> delete({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    final r = await this._dio.delete(
          endpoint,
          data: data,
        );
    return r;
  }
}
