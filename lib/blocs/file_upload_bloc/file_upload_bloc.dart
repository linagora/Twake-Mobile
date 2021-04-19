import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_event.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_state.dart';

export 'package:twake/blocs/file_upload_bloc/file_upload_event.dart';
export 'package:twake/blocs/file_upload_bloc/file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final repository;

  FileUploadBloc(this.repository) : super(NothingToUpload());

  @override
  Stream<FileUploadState> mapEventToState(FileUploadEvent event) {
    throw UnimplementedError();
  }
}
