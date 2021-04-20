import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_event.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_state.dart';
import 'package:twake/repositories/file_upload_repository.dart';

export 'package:twake/blocs/file_upload_bloc/file_upload_event.dart';
export 'package:twake/blocs/file_upload_bloc/file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final FileUploadRepository repository;

  FileUploadBloc(this.repository) : super(NothingToUpload());

  @override
  Stream<FileUploadState> mapEventToState(FileUploadEvent event) async* {
    if (event is StartUpload) {
      final size = await event.size;
      final fileName = event.fileName;
      final cancelToken = CancelToken();

      repository.upload(
        payload: event.payload,
        onSuccess: (Map<String, dynamic> response) {
          this.add(FinishUpload(
            id: response['id'],
            fileName: response['filename'],
            size: int.parse(response['size']),
          ));
        },
        onError: (e) {
          this.add(ErrorUpload(
            reason: e,
            fileName: fileName,
            size: size,
          ));
        },
        cancelToken: cancelToken,
      );

      yield FileUploading(
        cancelToken: cancelToken,
        fileName: fileName,
        size: size,
      );
    } else if (event is CancelUpload) {
      repository.cancelUpload(event.cancelToken);
      yield FileUploadCancelled();
    } else if (event is FinishUpload) {
      yield FileUploaded(
        event.id,
        fileName: event.fileName,
        size: event.size,
      );
    } else if (event is ErrorUpload) {
      yield FileUploadFailed(
        event.reason,
        fileName: event.fileName,
        size: event.size,
      );
    }
  }
}
