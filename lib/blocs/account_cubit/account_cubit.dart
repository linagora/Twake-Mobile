import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_bloc.dart';
import 'package:twake/models/language_option.dart';
import 'package:twake/repositories/account_repository.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_state.dart';

enum AccountFlowStage {
  info,
  edit,
}

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository accountRepository;
  final FileUploadBloc fileUploadBloc;
  StreamSubscription _fileUploadSubscription;

  AccountCubit(this.accountRepository, {this.fileUploadBloc})
      : super(AccountInitial(stage: AccountFlowStage.info)) {
    // Listening for FileUploadBloc event
    _fileUploadSubscription = fileUploadBloc.listen((state) {
      print('File upload state: $state');

      if (state is FileUploaded) {
        // final uploadedFile = state.files.first;
        // final link = uploadedFile.toJson();
        // print('Link: $link');
        for (var file in state.files) {
          final link = file.toJson();
          print('Link: $link');
        }
        emit(AccountPictureUploadSuccess());
        fileUploadBloc.add(ClearUploads());
      }
    });
  }

  Future<void> fetch({bool fromNetwork = true}) async {
    emit(AccountLoadInProgress());

    if (fromNetwork) await accountRepository.reload();

    final availableLanguages =
        accountRepository.language.options ?? <LanguageOption>[];
    final currentLanguage = accountRepository.selectedLanguage();
    final languageTitle = currentLanguage.title;

    emit(AccountLoadSuccess(
      userName: accountRepository.userName.value,
      firstName: accountRepository.firstName.value,
      lastName: accountRepository.lastName.value,
      picture: accountRepository.picture.value,
      language: languageTitle,
      availableLanguages: availableLanguages,
    ));
  }

  void updateInfo({
    // In the local storage :)
    String firstName,
    String lastName,
    String languageTitle,
    String oldPassword,
    String newPassword,
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
            ? accountRepository.languageCodeFromTitle(languageTitle)
            : '';
    accountRepository.update(
      newFirstName: firstName,
      newLastName: lastName,
      newLanguage: languageCode ?? '',
      oldPassword: oldPassword,
      newPassword: newPassword,
      shouldUpdateCache: shouldUpdateCache,
    );
    emit(AccountUpdateSuccess(
      firstName: accountRepository.firstName.value,
      lastName: accountRepository.lastName.value,
      language: accountRepository.selectedLanguage().title,
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
  }

  Future<void>saveInfo() async {
    emit(AccountSaveInProgress());
    final result = await accountRepository.patch();
    if (result is AccountRepository) {
      emit(AccountSaveSuccess());
    } else {
      emit(AccountSaveFailure());
    }
  }

  void updateImage(List<int> bytes) { // For local update.
    emit(AccountPictureUpdateSuccess(bytes));
  }

  Future<void> uploadImage(List<int> bytes) async {
    emit(AccountPictureUploadInProgress());
    print('Call with bytes: $bytes');
    fileUploadBloc.add(StartUpload(
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
