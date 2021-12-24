import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';

enum FileItemDownloadStatus {
  init,
  downloadInProgress,
  downloadSuccessful,
  downloadFailed,
}

class FileDownloading extends Equatable {
  final File file;
  final FileItemDownloadStatus downloadStatus;
  final String? downloadTaskId;
  final String? savedPath;

  FileDownloading({
    required this.file,
    required this.downloadStatus,
    this.downloadTaskId,
    this.savedPath,
  });

  FileDownloading copyWith({
    File? file,
    FileItemDownloadStatus? downloadStatus,
    String? savedPath,
    String? downloadTaskId,
  }) {
    return FileDownloading(
      file: file ?? this.file,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      savedPath: savedPath ?? this.savedPath,
      downloadTaskId: downloadTaskId ?? this.downloadTaskId,
    );
  }

  @override
  List<Object?> get props => [file, downloadStatus, downloadTaskId, savedPath];
}
