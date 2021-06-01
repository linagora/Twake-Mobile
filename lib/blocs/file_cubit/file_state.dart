part of 'file_cubit.dart';

abstract class FileState extends Equatable {
  const FileState();
}

class FileInitial extends FileState {
  @override
  List<Object> get props => [];
}

class FileUploadInProgress extends FileState {
  final CancelToken cancelToken;
  final String name;
  final int size;

  FileUploadInProgress({
    required this.cancelToken,
    required this.name,
    required this.size,
  });

  @override
  List<Object?> get props => [name];
}

class FileUploadFailed extends FileState {
  final String reason;

  FileUploadFailed({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class FileUploadSuccess extends FileState {
  final List<File> files;

  FileUploadSuccess({required this.files});

  @override
  List<Object?> get props => [files];
}

class FileDownloadInProgress extends FileState {
  final CancelToken cancelToken;
  final File file;

  const FileDownloadInProgress({
    required this.cancelToken,
    required this.file,
  });

  @override
  List<Object?> get props => [file];
}

class FileDownloadFailed extends FileState {
  final String reason;

  const FileDownloadFailed({
    required this.reason,
  });

  @override
  List<Object?> get props => [reason];
}

class FileDownloadSuccess extends FileState {
  final String downloadPath;

  const FileDownloadSuccess({
    required this.downloadPath,
  });

  @override
  List<Object?> get props => [downloadPath];
}
