import 'package:equatable/equatable.dart';

abstract class FileUploadState extends Equatable {
  final String fileName;
  final int size;

  const FileUploadState({this.fileName, this.size});
}

class NothingToUpload extends FileUploadState {
  const NothingToUpload();

  @override
  List<Object> get props => [];
}

class FileUploading extends FileUploadState {
  const FileUploading({String fileName, int size})
      : super(fileName: fileName, size: size);

  @override
  List<Object> get props => [fileName];
}

class FileUploadFailed extends FileUploadState {
  final String reason;

  const FileUploadFailed(this.reason, {String fileName, int size})
      : super(fileName: fileName, size: size);

  @override
  List<Object> get props => [reason];
}

class FileUploaded extends FileUploadState {
  final String id;

  const FileUploaded(this.id, {String fileName, int size})
      : super(fileName: fileName, size: size);

  @override
  List<Object> get props => [id];
}
