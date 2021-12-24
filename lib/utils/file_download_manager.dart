import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';

class FileDownloadManager {

  Future<String?> downloadFile({
    required String downloadUrl,
    required String savedDir,
    required String fileName,
    String? token,
  }) async {
    final taskId = await FlutterDownloader.enqueue(
        fileName: fileName,
        url: downloadUrl,
        savedDir: savedDir,
        headers: {'Authorization': 'Bearer $token'},
        saveInPublicStorage: true,
        showNotification: false);
    return taskId;
  }

  void cancelDownloadingFile({required String downloadTaskId}) {
    FlutterDownloader.cancel(taskId: downloadTaskId);
  }

  Future<bool> openDownloadedFile({required String downloadTaskId}) async {
    return await FlutterDownloader.open(taskId: downloadTaskId);
  }
}