import 'dart:io' as io;
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/repositories/file_repository.dart';

export 'package:twake/models/file/file.dart';

part 'file_state.dart';

class FileCubit extends Cubit<FileState> {
  late final FileRepository _repository;

  FileCubit({FileRepository? repository}) : super(FileInitial()) {
    if (repository == null) {
      repository = FileRepository();
    }
    _repository = repository;
  }

  void upload({required String path}) async {
    final name = path.split('/').last;
    final cancelToken = CancelToken();
    final size = io.File(path).lengthSync();

    emit(FileUploadInProgress(
      name: name,
      cancelToken: cancelToken,
      size: size,
    ));

    List<File> uploadedFiles = [];
    try {
      uploadedFiles = await _repository.upload(
        path: path,
        name: name,
        cancelToken: cancelToken,
      );
    } catch (e) {
      Logger().e('Error occured during file upload:\n$e');
      emit(FileUploadFailed(reason: e.toString()));
      return;
    }

    emit(FileUploadSuccess(files: uploadedFiles));
  }

  Future<File> getById({required String id}) async {
    final file = await _repository.getById(id: id);

    return file;
  }

  void download({required File file}) async {
    // TODO: implement download functionality
  }
}
