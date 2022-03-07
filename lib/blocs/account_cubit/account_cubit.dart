import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/account_repository.dart';
import 'package:twake/services/service_bundle.dart';

export 'package:twake/models/account/account.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  late final AccountRepository _repository;

  AccountCubit({AccountRepository? repository}) : super(AccountInitial()) {
    // issue #731
    Segment.setContext({});

    if (repository == null) {
      repository = AccountRepository();
    }
    _repository = repository;
  }

  Future<void> fetch(
      {String? userId, bool sendAnalyticAfterFetch = false}) async {
    emit(AccountLoadInProgress());

    if (userId == null && Globals.instance.userId != null) {
      userId = Globals.instance.userId;
    }

    var isTracked = false;
    await for (var account in _repository.fetch(userId: userId)) {
      emit(AccountLoadSuccess(account: account, hash: account.hash));

      // tracking
      if (sendAnalyticAfterFetch && !isTracked && !kDebugMode) {
        isTracked = true;
        Segment.identify(userId: account.providerId ?? account.id).then((r) {
          Segment.track(eventName: 'twake-mobile:open_client');
        }).onError((e, s) {
          Logger().d('Error while send tracking info: $e');
        });
      }

      _repository.setRecentWorkspace();
    }
  }

  // Fetch the user from local storage and return it, without updating cubit's state
  Future<Account> fetchStateless({required String userId}) async {
    Account account;
    try {
      account = await _repository.localFetch(userId: userId);
    } catch (_) {
      Logger().v('Unable to fetch user: $userId from local store');
      account = await _repository.remoteFetch(userId: userId);
    }

    return account;
  }

  // following the bloc pattern, not to call directly
  setRecentWorkspace() {
    _repository.setRecentWorkspace();
  }
}
