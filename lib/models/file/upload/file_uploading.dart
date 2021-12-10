import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';

class FileUploading extends Equatable {

  final int id;
  final File? file; // will available when it was uploaded/editing
  final String? sourcePath;
  final String? sourceName;
  final FileItemUploadStatus uploadStatus;
  final CancelToken? cancelToken;

  FileUploading(
      {this.file,
      required this.id,
      this.sourcePath,
      this.sourceName,
      required this.uploadStatus,
      this.cancelToken});

  FileUploading copyWith({
    File? file,
    String? sourcePath,
    String? sourceName,
    FileItemUploadStatus? uploadStatus,
    CancelToken? cancelToken,
  }) {
    return FileUploading(
      id: this.id,
      file: file ?? this.file,
      sourcePath: sourcePath ?? this.sourcePath,
      sourceName: sourceName ?? this.sourceName,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  List<Object?> get props =>
      [id, file, sourcePath, sourceName, uploadStatus, cancelToken];
}

enum FileItemUploadStatus {
  init,
  uploading,
  uploaded,
  failed
}