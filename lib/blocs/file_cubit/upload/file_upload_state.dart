import 'package:equatable/equatable.dart';
import 'package:twake/models/file/upload/file_uploading.dart';

enum FileUploadStatus {
  init,
  uploading,
  uploadFinished   //can be success or fail
}

class FileUploadState extends Equatable {
  final FileUploadStatus fileUploadStatus;
  final List<FileUploading> listFileUploading;
  final String channel;

  const FileUploadState({
    this.fileUploadStatus = FileUploadStatus.init,
    this.listFileUploading = const [], 
    this.channel = ''
  });

  FileUploadState copyWith({
    FileUploadStatus? fileUploadStatus,
    List<FileUploading>? listFileUploading, 
    String? channel,
  }) {
    return FileUploadState(
      fileUploadStatus: fileUploadStatus ?? this.fileUploadStatus,
      listFileUploading: listFileUploading ?? this.listFileUploading,
      channel: channel ?? this.channel);
  }

  @override
  List<Object> get props => [fileUploadStatus, listFileUploading, channel];
}
