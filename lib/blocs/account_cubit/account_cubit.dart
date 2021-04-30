import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/language_option.dart';
import 'package:twake/models/password_values.dart';
import 'package:twake/repositories/account_repository.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository accountRepository;

  AccountCubit(this.accountRepository) : super(AccountInitial());

  Future<void> fetch() async {
    emit(AccountLoading());
    await accountRepository.reload();

    final availableLanguages = accountRepository.language.options;
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
    final languageCode = accountRepository.languageCodeFromTitle(languageTitle);
    await accountRepository.patch(
      newFirstName: firstName,
      newLastName: lastName,
      newLanguage: languageCode,
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
}
