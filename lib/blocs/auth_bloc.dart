import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/auth_event.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/init.dart';
import 'package:twake/states/auth_state.dart';

export 'package:twake/events/auth_event.dart';
export 'package:twake/states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc(this.repository) : super(AuthInitializing()) {
    Api().resetAuthentication = resetAuthentication;
  }

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthInitialize) {
      // print(repository.tokenIsValid());
      switch (repository.tokenIsValid()) {
        case TokenStatus.Valid:
          final InitData initData = await initMain();
          yield Authenticated(initData);
          break;
        case TokenStatus.AccessExpired:
          final InitData initData = await initMain();
          yield Authenticated(initData);
          break;
          switch (await repository.prolongToken()) {
            case AuthResult.Ok:
              final InitData initData = await initMain();
              yield Authenticated(initData);
              break;
            case AuthResult.NetworkError:
              // TODO Work out the case with absent network connection
              final InitData initData = await initMain();
              yield Authenticated(initData);
              break;
            case AuthResult.WrongCredentials:
              yield Unauthenticated();
          }
          break;
        case TokenStatus.BothExpired:
          yield Unauthenticated(message: 'Session expired');
      }
    } else if (event is Authenticate) {
      yield Authenticating();
      final result = await repository.authenticate(
        username: event.username,
        password: event.password,
      );
      if (result == AuthResult.WrongCredentials) {
        yield Unauthenticated(message: 'Wrong credentials');
      } else if (result == AuthResult.NetworkError) {
        yield AuthenticationError();
      } else {
        final InitData initData = await initMain();
        yield Authenticated(initData);
      }
    } else if (event is SetAuthData) {
      yield Authenticating();
      await repository.setAuthData(event.authData);
      final InitData initData = await initMain();
      yield Authenticated(initData);
    } else if (event is ResetAuthentication) {
      if (event.message == null) {
        repository.fullClean();
      } else {
        repository.clean();
      }
      yield Unauthenticated(message: event.message);
    }
  }

  void resetAuthentication() {
    this.add(ResetAuthentication(message: 'Session has expired'));
  }
}
