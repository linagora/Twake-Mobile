import 'package:dio/dio.dart';
import 'package:twake/services/service_bundle.dart';

class FileUploadRepository {
  Api _api = Api();
  Logger _logger = Logger();

  void upload(
      {FormData payload,
      Function(Map<String, dynamic> response) onSuccess,
      Function(String reason) onError,
      CancelToken cancelToken}) {
    _api
        .post(Endpoint.fileUpload, body: payload, cancelToken: cancelToken)
        .then((r) => onSuccess(r))
        .onError((e, s) {
      onError(e.toString());
      _logger.e("ERROR UPLOADING FILE:\n$s");
    });
  }

  void cancelUpload(CancelToken cancelToken) {
    cancelToken.cancel('User aborted');
  }
}
