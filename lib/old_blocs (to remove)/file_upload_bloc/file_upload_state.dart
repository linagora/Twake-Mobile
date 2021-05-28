import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/uploaded_file.dart';

abstract class FileUploadState extends Equatable {
  final String? filename;
  final int? size;

  const FileUploadState({this.filename, this.size});
}

class NothingToUpload extends FileUploadState {
  const NothingToUpload();

  @override
  List<Object> get props => [];
}

class FileUploading extends FileUploadState {
  final CancelToken? cancelToken;

  const FileUploading({
    this.cancelToken,
    String? filename,
    int? size,
  }) : super(filename: filename, size: size);

  @override
  List<Object?> get props => [filename];
}

class FileUploadFailed extends FileUploadState {
  final String? reason;

  const FileUploadFailed(this.reason, {String? filename, int? size})
      : super(filename: filename, size: size);

  @override
  List<Object?> get props => [reason];
}

class FileUploadCancelled extends FileUploadState {
  const FileUploadCancelled();

  @override
  List<Object> get props => [];
}

class FileUploaded extends FileUploadState {
  final List<UploadedFile> files;

  const FileUploaded(this.files);

  @override
  List<Object> get props => [files];
}
