import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class FileUploadEvent extends Equatable {
  const FileUploadEvent();
}

class StartUpload extends FileUploadEvent {
  final String path;
  final String workspaceId;
  const StartUpload({this.path, this.workspaceId});

  FormData get payload => FormData.fromMap({
        'file': MultipartFile.fromFile(path),
        'workspace_id': workspaceId,
      });

  @override
  List<Object> get props => [path];
}

class CancelUpload extends FileUploadEvent {
  const CancelUpload();

  @override
  List<Object> get props => [];
}
