import 'package:dio/dio.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class FileRepository {
  final _api = ApiService.instance;

  final _files = <File>[];

  FileRepository();

  Future<List<File>> upload({
    required String path,
    String? name,
    required CancelToken cancelToken,
  }) async {
    final multipartFile = await MultipartFile.fromFile(path, filename: name);
    final formData = FormData.fromMap({
      'file': multipartFile,
      'company_id': Globals.instance.companyId,
    });
    final result = await _api.post(
      endpoint: Endpoint.fileUpload,
      data: formData,
      cancelToken: cancelToken,
    );

    final file = File.fromJson(json: result);

    _files.add(file);

    return _files;
  }

  Future<String> download({required File file}) async {
    // TODO implement download
  }

  void clearFiles() {
    _files.clear();
  }

  void cancelUpload(CancelToken cancelToken) {
    cancelToken.cancel('User aborted');
  }
}
