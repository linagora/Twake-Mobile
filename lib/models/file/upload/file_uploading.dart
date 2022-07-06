import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/models/file/message_file.dart';

class FileUploading extends Equatable {
  final int id;
  final File? file; // will available when it was uploaded/editing
  final MessageFile? messageFile;
  final LocalFile? sourceFile;
  final FileItemUploadStatus uploadStatus;
  final CancelToken? cancelToken;

  FileUploading(
      {this.file,
      this.messageFile,
      required this.id,
      this.sourceFile,
      required this.uploadStatus,
      this.cancelToken});

  FileUploading copyWith({
    File? file,
    MessageFile? messageFile,
    LocalFile? sourceFile,
    String? sourceName,
    FileItemUploadStatus? uploadStatus,
    CancelToken? cancelToken,
  }) {
    return FileUploading(
      id: this.id,
      file: file ?? this.file,
      messageFile: messageFile ?? this.messageFile,
      sourceFile: sourceFile ?? this.sourceFile,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  List<Object?> get props =>
      [id, file, messageFile, sourceFile, uploadStatus, cancelToken];
}

enum FileItemUploadStatus { init, uploading, uploaded, failed }
