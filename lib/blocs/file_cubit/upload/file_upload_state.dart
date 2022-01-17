import 'package:equatable/equatable.dart';
import 'package:twake/models/file/upload/file_uploading.dart';

enum FileUploadStatus {
  init,
  inProcessing,
  finished
}

class FileUploadState extends Equatable {
  final FileUploadStatus fileUploadStatus;
  final List<FileUploading> listFileUploading;

  const FileUploadState({
    this.fileUploadStatus = FileUploadStatus.init,
    this.listFileUploading = const [], 
  });

  FileUploadState copyWith({
    FileUploadStatus? fileUploadStatus,
    List<FileUploading>? listFileUploading, 
  }) {
    return FileUploadState(
      fileUploadStatus: fileUploadStatus ?? this.fileUploadStatus,
      listFileUploading: listFileUploading ?? this.listFileUploading,
    );
  }

  @override
  List<Object> get props =>
      [fileUploadStatus, listFileUploading];
}
