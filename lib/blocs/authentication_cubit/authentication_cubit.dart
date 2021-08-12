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
      emit(AuthenticationInitial());
    }
  }

  Future<bool> authenticate() async {
    emit(AuthenticationInProgress());
    final authenticated = await _repository.webviewAuthenticate();
    if (authenticated) {
      emit(AuthenticationSuccess());
      _repository.startTokenValidator();
      await syncData();
    } else {
      emit(AuthenticationInitial());
    }
    return authenticated;
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

  void logout() async {
    await _repository.logout();
    emit(AuthenticationInitial());
    SocketIOService.instance.disconnect();
  }

  void registerDevice() async {
    await _repository.registerDevice();
  }

  @override
  Future<void> close() {
    _networkSubscription.cancel();
    return super.close();
  }
}
