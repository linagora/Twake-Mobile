import 'package:equatable/equatable.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';

enum FileUploadStatus {
  init,
  inProcessing,
  finished
}

class FileUploadState extends Equatable {
  final FileUploadStatus fileUploadStatus;
  final List<FileUploading> listFileUploading;
  final List<LocalFile> listLocalPickedFile;

  const FileUploadState({
    this.fileUploadStatus = FileUploadStatus.init,
    this.listFileUploading = const [], 
    this.listLocalPickedFile = const []
  });

  FileUploadState copyWith({
    FileUploadStatus? fileUploadStatus,
    List<FileUploading>? listFileUploading, 
    List<LocalFile>? localFilePaths
  }) {
    return FileUploadState(
      fileUploadStatus: fileUploadStatus ?? this.fileUploadStatus,
      listFileUploading: listFileUploading ?? this.listFileUploading,
      listLocalPickedFile: localFilePaths ?? this.listLocalPickedFile,
    );
  }

  @override
  List<Object> get props =>
      [fileUploadStatus, listFileUploading, listLocalPickedFile];
}
