import 'package:dio/dio.dart';
import 'package:twake/models/uploaded_file.dart';
import 'package:twake/services/service_bundle.dart';

class FileUploadRepository {
  Api _api = Api();
  Logger _logger = Logger();

  List<UploadedFile> files = [];

  // FileUploadRepository() {
  //   print('FileUploadRepository initialization');
  // }

  void upload({
    FormData payload,
    String endpoint = Endpoint.fileUpload,
    Function(Map<String, dynamic> response) onSuccess,
    Function(String reason) onError,
    CancelToken cancelToken,
  }) {
    print('Payload fields in upload request: ${payload.fields}');
    _api
        .post(endpoint, body: payload, cancelToken: cancelToken)
        .then((r) {
      this.files.add(UploadedFile.fromJson(r));
      onSuccess(r);
    }).onError((e, s) {
      onError(e.toString());
      _logger.e("ERROR UPLOADING FILE:\n$e\n$s");
    });
  }

  void clearFiles() {
    files.clear();
  }

  void cancelUpload(CancelToken cancelToken) {
    cancelToken.cancel('User aborted');
  }
}
