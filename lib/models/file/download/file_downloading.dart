import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';

enum FileItemDownloadStatus {
  init,
  downloadInProgress,
  downloadSuccessful,
  downloadFailed,
}

class FileDownloading extends Equatable {
  final File? file;
  final MessageFile? messageFile;
  final FileItemDownloadStatus downloadStatus;
  final String? downloadTaskId;
  final String? savedPath;

  FileDownloading({
    this.file,
    this.messageFile,
    required this.downloadStatus,
    this.downloadTaskId,
    this.savedPath,
  });

  FileDownloading copyWith({
    File? file,
    MessageFile? messageFile,
    FileItemDownloadStatus? downloadStatus,
    String? savedPath,
    String? downloadTaskId,
  }) {
    return FileDownloading(
      file: file ?? this.file,
      messageFile: messageFile ?? this.messageFile,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      savedPath: savedPath ?? this.savedPath,
      downloadTaskId: downloadTaskId ?? this.downloadTaskId,
    );
  }

  @override
  List<Object?> get props =>
      [file, messageFile, downloadStatus, downloadTaskId, savedPath];
}
