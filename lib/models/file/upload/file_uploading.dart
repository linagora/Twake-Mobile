import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/local_file.dart';

class FileUploading extends Equatable {

  final int id;
  final File? file; // will available when it was uploaded/editing
  final LocalFile? sourceFile;
  final FileItemUploadStatus uploadStatus;
  final CancelToken? cancelToken;

  FileUploading(
      {this.file,
      required this.id,
      this.sourceFile,
      required this.uploadStatus,
      this.cancelToken});

  FileUploading copyWith({
    File? file,
    LocalFile? sourceFile,
    String? sourceName,
    FileItemUploadStatus? uploadStatus,
    CancelToken? cancelToken,
  }) {
    return FileUploading(
      id: this.id,
      file: file ?? this.file,
      sourceFile: sourceFile ?? this.sourceFile,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  List<Object?> get props =>
      [id, file, sourceFile, uploadStatus, cancelToken];
}

enum FileItemUploadStatus {
  init,
  uploading,
  uploaded,
  failed
}