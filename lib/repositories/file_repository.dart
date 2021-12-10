import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/upload/file_uploading_option.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:http_parser/http_parser.dart';

class FileRepository {
  final _api = ApiService.instance;

  FileRepository();

  Future<File> upload({
    required String sourcePath,
    String? fileName,
    required CancelToken cancelToken,
    FileUploadingOption? fileUploadingOption
  }) async {
    final mimeType = lookupMimeType(sourcePath) ?? 'application/octet-stream';
    final multipartFile = await MultipartFile.fromFile(
        sourcePath,
        filename: fileName,
        contentType: MediaType.parse(mimeType)
    );
    final formData = FormData.fromMap({
      'file': multipartFile,
    });
    String _endpoint = sprintf(Endpoint.files, [Globals.instance.companyId]);
    if(fileUploadingOption != null) {
      final queryParams = <String, dynamic> {
        'thumbnail_sync': fileUploadingOption.thumbnailSync.toString(),
        'filename': fileUploadingOption.fileName,
        'type': fileUploadingOption.type,
        'total_size': fileUploadingOption.totalSize.toString(),
      };
      _endpoint = Uri(path: _endpoint, queryParameters: queryParams).toString();
    }
    final result = await _api.post(
      endpoint: _endpoint,
      data: formData,
      cancelToken: cancelToken,
      key: 'resource',
    );
    return File.fromJson(result);
  }

  Future<File> getFileData({required String id}) async {
    final result = await _api.get(
      endpoint: sprintf(Endpoint.fileMetadata, [Globals.instance.companyId, id]),
      key: 'resource',
    );
    return File.fromJson(result);
  }

}
