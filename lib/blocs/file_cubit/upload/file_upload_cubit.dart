import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/models/attachment/attachment.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/models/file/upload/file_uploading_option.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/repositories/file_repository.dart';

/// This cubit is used for both uploading files in-chat and receive sharing file
/// There are two file streams here to be easier when listening stream in two scenarios
class FileUploadCubit extends Cubit<FileUploadState> {
  late final FileRepository _repository;

  /// Use a StreamController to keep it separate from bloc's stream
  /// To have better management for the state (uploaded/failed) of File Uploading item

  // For file in-chat
  late StreamController<FileUploading> _listUploadingStreamController;
  late Stream<FileUploading> streamListUploading;

  void addFileUploadingToStream(FileUploading? fileUploading) {
    if (fileUploading == null) return;
    if (_listUploadingStreamController.isClosed) return;
    _listUploadingStreamController.add(fileUploading);
  }

  void initFileUploadingStream() {
    _listUploadingStreamController =
        StreamController<FileUploading>.broadcast();
    streamListUploading = _listUploadingStreamController.stream;
  }

  void closeListUploadingStream() {
    _listUploadingStreamController.close();
  }

  // For file sharing
  late StreamController<FileUploading> _listSharingStreamController;
  late Stream<FileUploading> streamListSharingFile;

  void initSharingFilesStream() {
    _listSharingStreamController = StreamController<FileUploading>.broadcast();
    streamListSharingFile = _listSharingStreamController.stream;
  }

  void addFileSharingToStream(FileUploading? fileUploading) {
    if (fileUploading == null) return;
    if (_listSharingStreamController.isClosed) return;
    _listSharingStreamController.add(fileUploading);
  }

  void closeListSharingStream() {
    _listSharingStreamController.close();
  }

  FileUploadCubit({FileRepository? repository}) : super(FileUploadState()) {
    if (repository == null) {
      repository = FileRepository();
    }
    _repository = repository;
  }

  Future<void> upload({
    required LocalFile sourceFile,
    String? companyId,
    required SourceFileUploading sourceFileUploading,
  }) async {
    List<FileUploading> listFileUploading = [...state.listFileUploading];
    final newId = listFileUploading.length;

    // add new file uploading request
    final newFileUploading = FileUploading(
        id: newId,
        sourceFile: sourceFile,
        uploadStatus: FileItemUploadStatus.uploading,
        cancelToken: CancelToken());
    emit(state.copyWith(
        fileUploadStatus: FileUploadStatus.inProcessing,
        listFileUploading: listFileUploading..add(newFileUploading)));

    try {
      await _startUploadingFile(
        newFileUploading,
        companyId: companyId,
        sourceFileUploading: sourceFileUploading,
      );
    } catch (e) {
      Logger().e('Error occurred during file upload:\n$e');
      _handleUploadFileError(
        fileErrorId: newId,
        sourceFileUploading: sourceFileUploading,
      );
    }
  }

  Future<void> addAlreadyUploadedFile({
    required File existsFile,
  }) async {
    List<FileUploading> listFileUploading = [...state.listFileUploading];
    final newId = listFileUploading.length;

    final existsFileUploading = FileUploading(
      id: newId,
      file: existsFile,
      uploadStatus: FileItemUploadStatus.uploaded,
    );

    emit(state.copyWith(
        fileUploadStatus: FileUploadStatus.inProcessing,
        listFileUploading: listFileUploading..add(existsFileUploading)));
  }

  void retryUpload(
    List<FileUploading> listFileUploading, {
    required SourceFileUploading sourceFileUploading,
  }) async {
    for (var i = 0; i < listFileUploading.length; i++) {
      // update state of file uploading in list
      final fileUploading = listFileUploading[i];
      final updatedStateList = state.listFileUploading.map((file) {
        return file.id == fileUploading.id
            ? file.copyWith(uploadStatus: FileItemUploadStatus.uploading)
            : file;
      }).toList();
      emit(state.copyWith(
          fileUploadStatus: FileUploadStatus.inProcessing,
          listFileUploading: updatedStateList));

      try {
        await _startUploadingFile(
          fileUploading,
          sourceFileUploading: sourceFileUploading,
        );
      } catch (e) {
        Logger().e('Error occurred during file upload retrying:\n$e');
        _handleUploadFileError(
          fileErrorId: fileUploading.id,
          sourceFileUploading: sourceFileUploading,
        );
      }
    }
  }

  void removeFileUploading(FileUploading cancellingFile) {
    if (state.listFileUploading.isEmpty) return;
    if (state.listFileUploading.length == 1) {
      closeListUploadingStream();
      clearFileUploadingState(needToCancelInProcessingFile: true);
      Get.find<GalleryCubit>().galleryInit();
      return;
    }
    _cancelFileUploading(cancellingFile);
    final updatedStateList = [...state.listFileUploading];
    updatedStateList.removeWhere((file) => file.id == cancellingFile.id);
    emit(state.copyWith(listFileUploading: updatedStateList));
  }

  void clearFileUploadingState({bool needToCancelInProcessingFile = false}) {
    if (needToCancelInProcessingFile) {
      state.listFileUploading.forEach((fileUploading) {
        if (fileUploading.uploadStatus == FileItemUploadStatus.uploading) {
          _cancelFileUploading(fileUploading);
        }
      });
    }
    emit(state.copyWith(
      fileUploadStatus: FileUploadStatus.init,
      listFileUploading: [],
    ));
  }

  Future<void> startEditingFile(Message message) async {
    List<dynamic> uploadedFiles = message.files ?? [];
    if (uploadedFiles.isEmpty) return;
    List<FileUploading> listUploading = [];
    // Note: don't replace `for` to `forEach` here by `await` might not work
    // as expected
    for (var i = 0; i < uploadedFiles.length; i++) {
      final oldFileUploading =
          await _getFileUploaded(i, uploadedFiles[i], message);
      if (oldFileUploading != null) {
        listUploading.add(oldFileUploading);
      }
    }
    emit(state.copyWith(
      fileUploadStatus: FileUploadStatus.inProcessing,
      listFileUploading: listUploading,
    ));
  }

  Future<void> _startUploadingFile(
    FileUploading fileUploading, {
    String? companyId,
    required SourceFileUploading sourceFileUploading,
  }) async {
    // start uploading
    final uploadedFile = await _repository.upload(
      sourcePath: fileUploading.sourceFile!.path!,
      fileName: fileUploading.sourceFile!.name,
      cancelToken: fileUploading.cancelToken!,
      fileUploadingOption: FileUploadingOption(thumbnailSync: 1),
      companyId: companyId,
    );

    // update successful state
    if (state.listFileUploading.isEmpty) return;
    late FileUploading fileUploadingUpdated;
    final updatedStateList = state.listFileUploading.map((file) {
      if (file.id == fileUploading.id) {
        fileUploadingUpdated = file.copyWith(
            file: uploadedFile, uploadStatus: FileItemUploadStatus.uploaded);
        return fileUploadingUpdated;
      }
      return file;
    }).toList();
    emit(state.copyWith(listFileUploading: updatedStateList));

    // add to uploaded file to file uploading stream
    if (sourceFileUploading == SourceFileUploading.InChat) {
      addFileUploadingToStream(fileUploadingUpdated);
    } else if (sourceFileUploading == SourceFileUploading.FileSharing) {
      addFileSharingToStream(fileUploadingUpdated);
    }

    // Update to file download state
    // (any user own uploaded file no need to download again)
    Get.find<FileDownloadCubit>().addToDownloadStateAfterUploaded(
        file: uploadedFile, localPath: fileUploading.sourceFile!.path!);
  }

  void _handleUploadFileError({
    required int fileErrorId,
    required SourceFileUploading sourceFileUploading,
  }) {
    // update failed state
    if (state.listFileUploading.isEmpty) return;
    late FileUploading fileUploadingUpdated;
    final updatedStateList = state.listFileUploading.map((file) {
      if (file.id == fileErrorId - 1) {
        fileUploadingUpdated =
            file.copyWith(uploadStatus: FileItemUploadStatus.failed);
        return fileUploadingUpdated;
      }
      return file;
    }).toList();

    emit(state.copyWith(listFileUploading: updatedStateList));

    // add to uploaded file to file uploading stream
    if (sourceFileUploading == SourceFileUploading.InChat) {
      addFileUploadingToStream(fileUploadingUpdated);
    } else if (sourceFileUploading == SourceFileUploading.FileSharing) {
      addFileSharingToStream(fileUploadingUpdated);
    }
  }

  void _cancelFileUploading(FileUploading cancellingFile) {
    if (cancellingFile.uploadStatus == FileItemUploadStatus.uploading) {
      try {
        cancellingFile.cancelToken
            ?.cancel('user cancel uploading ${cancellingFile.id}');
      } catch (e) {
        Logger().e('Error occurred during cancel uploading:\n$e');
      }
    }
  }

  // In case the message is loaded from local DB (no connection),
  // the file will be a string of ID. Otherwise, it's file from remote
  Future<FileUploading?> _getFileUploaded(
      int index, dynamic fileDynamic, Message message) async {
    File? sentFile;

    /// TODO: Remove extracting data from [message] when attachment response has datetime, userId
    /// Currently attachment response does not have [createdAt], [updatedAt] and [userId]
    /// So, temporary get file's datetime from message's datetime
    int createdAt = message.createdAt;
    int updatedAt = message.updatedAt;
    String userId = message.userId;

    if (fileDynamic is Attachment) {
      sentFile = fileDynamic.toFile(
          userId: userId, createdAt: createdAt, updatedAt: updatedAt);
    } else if (fileDynamic is String) {
      sentFile = await Get.find<FileCubit>().getFileData(id: fileDynamic);
    }
    if (sentFile == null) return null;
    final oldFileUploading = FileUploading(
      id: index,
      uploadStatus: FileItemUploadStatus.uploaded,
      file: sentFile,
    );
    return oldFileUploading;
  }
}

enum SourceFileUploading { InChat, FileSharing }
