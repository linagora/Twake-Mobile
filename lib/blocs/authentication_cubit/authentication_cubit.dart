import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/authentication_repository.dart';
import 'package:twake/services/service_bundle.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  late final AuthenticationRepository _repository;
  late final StreamSubscription _networkSubscription;

  AuthenticationCubit({AuthenticationRepository? repository})
      : super(AuthenticationInitial()) {
    if (repository == null) {
      repository = AuthenticationRepository();
    }

    _repository = repository;

    _networkSubscription = Globals.instance.connection.listen((connection) {
      if (connection == Connection.connected) _repository.startTokenValidator();
    });

    checkAuthentication();
  }

  void checkAuthentication() async {
    emit(AuthenticationInProgress());
    bool authenticated = await _repository.isAuthenticated();

    if (authenticated) {
      emit(AuthenticationSuccess());
      _repository.startTokenValidator();
      await NavigatorService.instance.navigateOnNotificationLaunch();
    } else {
      authenticated = await _repository.webviewAuthenticate();
      if (authenticated) {
        emit(AuthenticationSuccess());
        await syncData();
      } else {
        emit(AuthenticationInitial());
      }
    }
  }

  void authenticate({
    required String username,
    required String password,
  }) async {
    emit(AuthenticationInProgress());
    final success = await _repository.authenticate(
      username: username,
      password: password,
    );

    if (!success) {
      emit(AuthenticationFailure(
        username: username,
        password: password,
      ));
      return;
    }
    _repository.startTokenValidator();

    emit(AuthenticationSuccess());

    await syncData();
  }

  Future<void> syncData() async {
    emit(PostAuthenticationSyncInProgress(progress: 0));

    final start = DateTime.now();

    final progress = InitService.syncData();

    try {
      await for (final p in progress) {
        emit(PostAuthenticationSyncInProgress(progress: p));
      }

      emit(PostAuthenticationSyncSuccess());
    } catch (e, stt) {
      Logger().e('Error occurred during initial data sync:\n$e\n$stt');
      emit(PostAuthenticationSyncFailed());
    }

    final end = DateTime.now();
    Logger().v('SYNC TOOK: ${end.difference(start).inSeconds} sec');
  }

  void logout() {
    _repository.logout();
    emit(AuthenticationInitial());
  }

  @override
  Future<void> close() {
    _networkSubscription.cancel();
    return super.close();
  }
}
