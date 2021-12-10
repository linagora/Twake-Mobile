import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';

abstract class FileState extends Equatable {
  const FileState();
}

class FileInitial extends FileState {
  @override
  List<Object> get props => [];
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
