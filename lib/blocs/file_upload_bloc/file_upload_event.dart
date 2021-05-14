import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';

abstract class FileUploadEvent extends Equatable {
  const FileUploadEvent();
}

class StartUpload extends FileUploadEvent {
  final String path;
  final List<int> bytes;
  final String workspaceId;
  final String endpoint;

  StartUpload({
    this.path = '',
    this.bytes,
    this.workspaceId,
    this.endpoint,
  });

  Future<FormData> payload() async {
    var almostUniqueName = '';
    if (path.isEmpty) {
      // If bytes is all we have.
      almostUniqueName =
          '${DateTime.now().microsecondsSinceEpoch.toString()}.jpg';
      print('Almost unique filename: $almostUniqueName');
    }

    final file = bytes != null && bytes.isNotEmpty
        ? MultipartFile.fromBytes(bytes, filename: almostUniqueName)
        : await MultipartFile.fromFile(path, filename: filename);

    return FormData.fromMap({
      'file': file,
      'workspace_id': workspaceId ?? ProfileBloc.selectedWorkspaceId,
    });
  }

  String get filename => basename(path);

  Future<int> get size => path.isNotEmpty
      ? File(path).length()
      : Future.value(Uint8List.fromList(bytes).elementSizeInBytes);

  @override
  List<Object> get props => [path, bytes];
}

class CancelUpload extends FileUploadEvent {
  final CancelToken cancelToken;

  const CancelUpload(this.cancelToken);

  @override
  List<Object> get props => [];
}

class FinishUpload extends FileUploadEvent {
  const FinishUpload();

  @override
  List<Object> get props => [];
}

class ErrorUpload extends FileUploadEvent {
  final String reason;
  final String filename;
  final int size;

  const ErrorUpload({this.reason, this.filename, this.size});

  @override
  List<Object> get props => [reason];
}

class ClearUploads extends FileUploadEvent {
  const ClearUploads();

  @override
  List<Object> get props => [];
}
