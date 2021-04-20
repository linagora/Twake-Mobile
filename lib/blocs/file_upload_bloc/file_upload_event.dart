import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

abstract class FileUploadEvent extends Equatable {
  const FileUploadEvent();
}

class StartUpload extends FileUploadEvent {
  final String path;
  final String workspaceId;

  StartUpload({this.path, this.workspaceId});

  FormData get payload => FormData.fromMap({
        'file': MultipartFile.fromFile(path),
        'workspace_id': workspaceId,
      });

  String get fileName {
    return basename(path);
  }

  Future<int> get size {
    return File(path).length();
  }

  @override
  List<Object> get props => [path];
}

class CancelUpload extends FileUploadEvent {
  final CancelToken cancelToken;

  const CancelUpload(this.cancelToken);

  @override
  List<Object> get props => [];
}

class FinishUpload extends FileUploadEvent {
  final String id;
  final String fileName;
  final int size;

  const FinishUpload({this.id, this.fileName, this.size});

  @override
  List<Object> get props => [id];
}

class ErrorUpload extends FileUploadEvent {
  final String reason;
  final String fileName;
  final int size;

  const ErrorUpload({this.reason, this.fileName, this.size});

  @override
  List<Object> get props => [reason];
}
