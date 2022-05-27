import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/models/file/download/file_downloading.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/upload/file_uploading_option.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/file_download_manager.dart';

class FileRepository {
  final _api = ApiService.instance;
  late final FileDownloadManager _fileDownloadManager;

  FileRepository({FileDownloadManager? fileDownloadManager}) {
    if (fileDownloadManager == null) {
      fileDownloadManager = FileDownloadManager();
    }
    _fileDownloadManager = fileDownloadManager;
  }

  Future<File> upload({
    required String sourcePath,
    String? fileName,
    required CancelToken cancelToken,
    FileUploadingOption? fileUploadingOption,
    String? companyId,
  }) async {
    final mimeType = lookupMimeType(sourcePath) ?? 'application/octet-stream';
    final multipartFile = await MultipartFile.fromFile(sourcePath,
        filename: fileName, contentType: MediaType.parse(mimeType));
    final formData = FormData.fromMap({
      'file': multipartFile,
    });
    String _endpoint =
        sprintf(Endpoint.files, [companyId ?? Globals.instance.companyId]);
    if (fileUploadingOption != null) {
      final queryParams = <String, dynamic>{
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
      endpoint:
          sprintf(Endpoint.fileMetadata, [Globals.instance.companyId, id]),
      key: 'resource',
    );
    return File.fromJson(result);
  }

  Future<Tuple2<String?, String>> downloadFile(
      {required FileDownloading fileDownloading}) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      externalStorageDirPath =
          await ExtStorage.getExternalStoragePublicDirectory(
              ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    final fileDestinationPath =
        '$externalStorageDirPath/${fileDownloading.file.metadata.name}';
    final taskId = await _fileDownloadManager.downloadFile(
        downloadUrl: fileDownloading.file.downloadUrl,
        savedDir: externalStorageDirPath,
        fileName: fileDownloading.file.metadata.name);
    return Tuple2(taskId, fileDestinationPath);
  }

  void cancelDownloadingFile({required String downloadTaskId}) {
    _fileDownloadManager.cancelDownloadingFile(downloadTaskId: downloadTaskId);
  }

  Future<bool> openDownloadedFile({required String downloadTaskId}) async {
    return await _fileDownloadManager.openDownloadedFile(
        downloadTaskId: downloadTaskId);
  }

  Future<List<ChannelFile>> fetchUserFilesFromCompany({
    required String userName,
    String? companyId,
  }) async {
    List<dynamic> remoteResult;
    final queryParameters = <String, dynamic>{
      'type': 'user_upload',
    };

    remoteResult = await _api.get(
      endpoint: sprintf(
          Endpoint.companyFiles, [companyId ?? Globals.instance.companyId]),
      queryParameters: queryParameters,
      key: 'resources',
    );

    var files = remoteResult
        .map((entry) => ChannelFile(entry['id'], userName, entry['created_at']))
        .toList();

    return files;
  }
}
