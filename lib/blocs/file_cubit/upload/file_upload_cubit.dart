import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/models/file/upload/file_uploading_option.dart';
import 'package:twake/repositories/file_repository.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  late final FileRepository _repository;

  FileUploadCubit({FileRepository? repository}) : super(FileUploadState()) {
    if (repository == null) {
      repository = FileRepository();
    }
    _repository = repository;
  }

  void upload({required String sourcePath}) async {
    final name = sourcePath.split('/').last;
    List<FileUploading> listFileUploading = [...state.listFileUploading];
    final newId = listFileUploading.length;

    // add new file uploading request
    final newFileUploading = FileUploading(
        id: newId,
        sourcePath: sourcePath,
        sourceName: name,
        uploadStatus: FileItemUploadStatus.uploading,
        cancelToken: CancelToken());
    emit(state.copyWith(
      listFileUploading: listFileUploading..add(newFileUploading)
    ));

    // begin uploading file
    try {
      final uploadedFile = await _repository.upload(
        sourcePath: newFileUploading.sourcePath!,
        fileName: newFileUploading.sourceName,
        cancelToken: newFileUploading.cancelToken!,
        fileUploadingOption: FileUploadingOption(thumbnailSync: 1)
      );

      // update successful state
      if(state.listFileUploading.isEmpty)
        return;
      final updatedStateList = state.listFileUploading.map((file) {
        return file.id == newId
          ? file.copyWith(
              file: uploadedFile,
              uploadStatus: FileItemUploadStatus.uploaded)
          : file;
      }).toList();
      emit(state.copyWith(listFileUploading: updatedStateList));

    } catch (e) {
      Logger().e('Error occurred during file upload:\n$e');

      // update failed state
      if(state.listFileUploading.isEmpty)
        return;
      final updatedStateList = state.listFileUploading.map((file) {
        return file.id == newId
            ? file.copyWith(uploadStatus: FileItemUploadStatus.failed)
            : file;
      }).toList();
      emit(state.copyWith(
          listFileUploading: updatedStateList));
    }
  }

  void cancelFileUploading(FileUploading cancellingFile) {
    if(state.listFileUploading.isEmpty)
      return;
    if(cancellingFile.uploadStatus == FileItemUploadStatus.uploading) {
      try {
        cancellingFile.cancelToken?.cancel('user cancel uploading ${cancellingFile.id}');
      } catch (e) {
        Logger().e('Error occurred during cancel uploading:\n$e');
      }
    }
    final updatedStateList = [...state.listFileUploading];
    updatedStateList.removeWhere((file) => file.id == cancellingFile.id);
    emit(state.copyWith(listFileUploading: updatedStateList));
  }

  void updateAfterSentAllFiles() {
    emit(state.copyWith(listFileUploading: []));
  }

  Future<void> startEditingFile(List<dynamic> uploadedFiles) async {
    if(uploadedFiles.isEmpty)
      return;
    List<FileUploading> listUploading = [];
    for (var i = 0; i < uploadedFiles.length; i++) {
      final oldFileUploading = await _getFileUploaded(i, uploadedFiles[i]);
      listUploading.add(oldFileUploading);
    }
    emit(state.copyWith(listFileUploading: listUploading));
  }

  // In case the message is loaded from local DB (no connection),
  // the file will be a string of ID. Otherwise, it's file from remote
  Future<FileUploading> _getFileUploaded(int index, dynamic fileDynamic) async {
    var sentFile;
    if(fileDynamic is File) {
      sentFile = fileDynamic;
    } else if(fileDynamic is String) {
      sentFile = await Get.find<FileCubit>().getFileData(id: fileDynamic);
    }
    final oldFileUploading = FileUploading(
      id: index,
      uploadStatus: FileItemUploadStatus.uploaded,
      file: sentFile,
    );
    return oldFileUploading;
  }

}
