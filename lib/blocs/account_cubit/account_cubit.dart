import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/account_repository.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository accountRepository;

  AccountCubit(this.accountRepository) : super(AccountInitial());

  Future<void> fetch() async {
    await accountRepository.reload();

    final languageCode = accountRepository.language.value;
    final availableLanguages = accountRepository.language.options;
    final currentLanguage = availableLanguages
        .firstWhere((language) => language.value == languageCode);
    final title = currentLanguage.title;

    emit(AccountLoaded(
      userName: accountRepository.userName.value,
      firstName: accountRepository.userName.value,
      lastName: accountRepository.lastName.value,
      picture: accountRepository.picture.value,
    ));
  }
}
