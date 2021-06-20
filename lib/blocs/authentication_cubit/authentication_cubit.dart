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
    final authenticated = await _repository.isAuthenticated();

    if (authenticated) {
      emit(AuthenticationSuccess());
      _repository.startTokenValidator();
      await NavigatorService.instance.navigateOnNotificationLaunch();
    } else {
      emit(AuthenticationInitial());
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
    emit(PostAuthenticationSyncInProgress());

    try {
      await InitService.syncData();
    } catch (e) {
      Logger().e('Error occurred during initial data sync:\n$e');
      emit(PostAuthenticationSyncFailed());
      return;
    }
    emit(AuthenticationSuccess());
    _repository.startTokenValidator();
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
