import 'package:dio/dio.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/services/service_bundle.dart';

class FileRepository {

  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  final Logger _logger = Logger();

  final _files = <File>[];

  // FileUploadRepository() {
  //   print('FileUploadRepository initialization');
  // }

  void upload({
    required FormData payload,
    String endpoint = Endpoint.fileUpload,
    Function(Map<String, dynamic>? response)? onSuccess,
    Function(String reason)? onError,
    CancelToken? cancelToken,
  }) {
    print('Payload fields in upload request: ${payload.fields}');
    // _api
    //     .post(endpoint: endpoint, data: payload, cancelToken: cancelToken)
    //     .then((r) {
    //   _files.add(File.fromJson(r));
    //   onSuccess!(r);
    // }).onError((dynamic e, s) {
    //   onError!(e.toString());
    //   _logger.e("ERROR UPLOADING FILE:\n$e\n$s");
    // });
  }

  void clearFiles() {
    _files.clear();
  }

  void cancelUpload(CancelToken cancelToken) {
    cancelToken.cancel('User aborted');
  }
}
