import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/account_repository.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  late final AccountRepository _repository;

  AccountCubit({AccountRepository? repository}) : super(AccountInitial()) {
    if (repository == null) {
      repository = AccountRepository();
    }
    _repository = repository;

    _repository.currentSet();
  }

  Future<void> fetch({String? userId}) async {
    emit(AccountLoadInProgress());

    if (userId == null && Globals.instance.userId != null)
      userId = Globals.instance.userId;

    await for (var account in _repository.fetch(userId: userId)) {
      emit(AccountLoadSuccess(account: account, hash: account.hash));
    }
  }

  Future<Account> fetchStateless({required String userId}) async {
    final account = await _repository.localFetch(userId: userId);

    return account;
  }
}
