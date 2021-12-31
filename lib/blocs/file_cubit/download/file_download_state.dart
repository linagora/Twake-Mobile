import 'package:equatable/equatable.dart';
import 'package:twake/models/file/download/file_downloading.dart';

class FileDownloadState extends Equatable {
  final List<FileDownloading> listFileDownloading;

  const FileDownloadState({
    this.listFileDownloading = const [],
  });

  FileDownloadState copyWith({List<FileDownloading>? listFileDownloading}) {
    return FileDownloadState(
      listFileDownloading: listFileDownloading ?? this.listFileDownloading,
    );
  }

  @override
  List<Object> get props => [listFileDownloading];
}
