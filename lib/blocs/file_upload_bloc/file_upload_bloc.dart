import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_event.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_state.dart';
import 'package:twake/repositories/file_upload_repository.dart';

export 'package:twake/blocs/file_upload_bloc/file_upload_event.dart';
export 'package:twake/blocs/file_upload_bloc/file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final FileUploadRepository repository = FileUploadRepository();

  FileUploadBloc() : super(NothingToUpload());

  @override
  Stream<FileUploadState> mapEventToState(FileUploadEvent event) async* {
    if (event is StartUpload) {
      final size = await event.size;
      final filename = event.filename;
      final cancelToken = CancelToken();

      repository.upload(
        payload: await event.payload(),
        onSuccess: (Map<String, dynamic> response) {
          this.add(FinishUpload());
        },
        onError: (e) {
          this.add(ErrorUpload(
            reason: e,
            filename: filename,
            size: size,
          ));
        },
        cancelToken: cancelToken,
      );

      yield FileUploading(
        cancelToken: cancelToken,
        filename: filename,
        size: size,
      );
    } else if (event is CancelUpload) {
      repository.cancelUpload(event.cancelToken);
      yield FileUploadCancelled();
    } else if (event is FinishUpload) {
      print('Yielding state FILE UPLOADED');
      yield FileUploaded(this.repository.files);
    } else if (event is ErrorUpload) {
      yield FileUploadFailed(
        event.reason,
        filename: event.filename,
        size: event.size,
      );
    } else if (event is ClearUploads) {
      repository.clearFiles();
      yield NothingToUpload();
    }
  }
}
