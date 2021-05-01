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

  AccountCubit(this.accountRepository)
      : super(AccountInitial(
          userName: accountRepository.userName.value,
          firstName: accountRepository.firstName.value,
          lastName: accountRepository.lastName.value,
          picture: accountRepository.picture.value,
          language: accountRepository.selectedLanguage().title,
          availableLanguages: accountRepository.language.options,
        )) {
    emit(AccountLoaded(
      userName: accountRepository.userName.value,
      firstName: accountRepository.firstName.value,
      lastName: accountRepository.lastName.value,
      picture: accountRepository.picture.value,
      language: accountRepository.selectedLanguage().title,
      availableLanguages: accountRepository.language.options,
    ));
  }

  Future<void> fetch() async {
    emit(AccountLoading());
    await accountRepository.reload();

    final availableLanguages =
        accountRepository.language.options ?? <LanguageOption>[];
    final currentLanguage = accountRepository.selectedLanguage();
    final languageTitle = currentLanguage.title;

    emit(AccountLoaded(
      userName: accountRepository.userName.value,
      firstName: accountRepository.firstName.value,
      lastName: accountRepository.lastName.value,
      picture: accountRepository.picture.value,
      language: languageTitle,
      availableLanguages: availableLanguages,
    ));
  }

  Future<void> updateInfo({
    String firstName,
    String lastName,
    String languageTitle,
    String oldPassword,
    String newPassword,
  }) async {
    emit(AccountSaving());
    final languageCode =
        (languageTitle != null && languageTitle.isNotReallyEmpty)
            ? accountRepository.languageCodeFromTitle(languageTitle)
            : '';
    await accountRepository.patch(
      newFirstName: firstName,
      newLastName: lastName,
      newLanguage: languageCode ?? '',
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    emit(AccountSaved(
      userName: accountRepository.userName.value,
      firstName: accountRepository.firstName.value,
      lastName: accountRepository.lastName.value,
      picture: accountRepository.picture.value,
      language: accountRepository.selectedLanguage().title,
      availableLanguages: accountRepository.language.options,
    ));
  }

  Future<void> updateImage(BuildContext context, String path) async {
    context.read<FileUploadBloc>().add(StartUpload(
          path: path,
          endpoint: Endpoint.accountPicture,
        ));
    context.read<FileUploadBloc>().listen((FileUploadState state) {
      if (state is FileUploaded) {
        fetch();
      }
    });
  }

  Future<void> updateAccountFlowStage(AccountFlowStage stage) async {
    emit(AccountFlowStageUpdated(stage));
  }
}
