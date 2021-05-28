import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_bloc.dart';
import 'package:twake/models/language_option.dart';
import 'package:twake/repositories/account_repository.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/utils/image_processor.dart';

part 'account_state.dart';

enum AccountFlowStage {
  info,
  edit,
}

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository? accountRepository;
  final FileUploadBloc? fileUploadBloc;
  late StreamSubscription _fileUploadSubscription;

  AccountCubit(this.accountRepository, {this.fileUploadBloc})
      : super(AccountInitial(stage: AccountFlowStage.info)) {
    // Listening for FileUploadBloc event
    _fileUploadSubscription = fileUploadBloc!.listen((state) {
      print('File upload state: $state');

      if (state is FileUploaded) {
        final files = state.files;
        if (files.length > 0) {
          final file = files.first;
          final link = file.file;
          emit(AccountPictureUploadSuccess(link: link));
        } else {
          emit(AccountPictureUploadFailure());
        }
        fileUploadBloc!.add(ClearUploads());
      }
      if (state is FileUploadFailed) {
        final reason = state.reason;
        emit(AccountPictureUploadFailure(message: reason));
      }
    });
  }

  Future<void> fetch({bool fromNetwork = true}) async {
    emit(AccountLoadInProgress());

    if (fromNetwork) await accountRepository!.reload();

    final availableLanguages =
        accountRepository!.language!.options ?? <LanguageOption>[];
    final currentLanguage = accountRepository!.selectedLanguage();
    final languageTitle = currentLanguage.title;

    emit(AccountLoadSuccess(
      userName: accountRepository!.userName!.value,
      firstName: accountRepository!.firstName!.value,
      lastName: accountRepository!.lastName!.value,
      picture: accountRepository!.picture!.value,
      language: languageTitle,
      availableLanguages: availableLanguages,
    ));
  }

  void updateInfo({
    // In the local storage :)
    required String firstName,
    required String lastName,
    String? languageTitle,
    required String oldPassword,
    String? newPassword,
    bool shouldUpdateCache = false,
  }) async {
    emit(AccountUpdateInProgress(
      firstName: firstName,
      lastName: lastName,
      language: languageTitle,
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
    final languageCode =
        (languageTitle != null && languageTitle.isNotReallyEmpty)
            ? accountRepository!.languageCodeFromTitle(languageTitle)
            : '';
    accountRepository!.update(
      newFirstName: firstName,
      newLastName: lastName,
      newLanguage: languageCode ?? '',
      oldPassword: oldPassword,
      newPassword: newPassword,
      shouldUpdateCache: shouldUpdateCache,
    );
    emit(AccountUpdateSuccess(
      firstName: accountRepository!.firstName!.value,
      lastName: accountRepository!.lastName!.value,
      language: accountRepository!.selectedLanguage().title,
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
  }

  Future<void> saveInfo() async {
    emit(AccountSaveInProgress());
    final result = await accountRepository!.patch();
    if (result is AccountRepository) {
      final firstName = result.firstName!.value;
      final lastName = result.lastName!.value;
      final language = result.language!.value;
      emit(AccountSaveSuccess(
        firstName: firstName,
        lastName: lastName,
        language: language,
      ));
    } else {
      emit(AccountSaveFailure());
    }
  }

  Future<void> updateImage() async {
    // For local update.
    emit(AccountPictureUpdateInProgress());

    // For picker failure cases.
    final fallbackImage = accountRepository!.picture!.value;

    List<PlatformFile>? files;
    try {
      files = (await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        withReadStream: true,
      ))
          ?.files;

      if (files != null && files.length > 0) {
        final imageFile = files.first;
        final path = imageFile.path!;
        print('Source path: $path');
        print('Source size: ${imageFile.size}');
        final file = File(path);
        final imageBytes = await processFile(file);

        final sizeSize = Uint8List.fromList(imageBytes).elementSizeInBytes;
        print('Reduced to: $sizeSize');
        emit(AccountPictureUpdateSuccess(imageBytes));
      } else {
        emit(AccountPictureUpdateFailure(
          message: 'No files selected',
          fallbackImage: fallbackImage,
        ));
      }
    } on PlatformException catch (e) {
      final message = "Unsupported operation" + e.toString();
      print(message);
      emit(AccountPictureUpdateFailure(
        message: message,
        fallbackImage: fallbackImage,
      ));
    } catch (e) {
      print(e);
      emit(AccountPictureUpdateFailure(
        message: e.toString(),
        fallbackImage: fallbackImage,
      ));
    }
  }

  Future<void> uploadImage(List<int> bytes) async {
    emit(AccountPictureUploadInProgress());
    fileUploadBloc!.add(StartUpload(
      bytes: bytes,
      endpoint: Endpoint.accountPicture,
    ));
  }

  void updateAccountFlowStage(AccountFlowStage stage) {
    emit(AccountFlowStageUpdateSuccess(stage: stage));
  }

  @override
  Future<void> close() async {
    await _fileUploadSubscription.cancel();
    return super.close();
  }
}
