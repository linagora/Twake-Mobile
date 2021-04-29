import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/repositories/account_repository.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository accountRepository;
  AccountCubit(this.accountRepository) : super(AccountInitial());
}
