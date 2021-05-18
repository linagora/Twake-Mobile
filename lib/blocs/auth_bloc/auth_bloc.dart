import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/connection_bloc/connection_bloc.dart' as cb;
import 'package:twake/blocs/auth_bloc/auth_event.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/init.dart';
import 'package:twake/blocs/auth_bloc/auth_state.dart';

export 'package:twake/blocs/auth_bloc/auth_event.dart';
export 'package:twake/blocs/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  var tempCreds = {};
  cb.ConnectionBloc connectionBloc;
  late StreamSubscription subscription;

  bool connectionLost = false;

  AuthBloc(this.repository, this.connectionBloc) : super(AuthInitializing()) {
    Api().resetAuthentication = resetAuthentication;
    Api().invalidateConfiguration = resetHost;
    subscription = connectionBloc.listen((cb.ConnectionState? state) async {
      if (state is cb.ConnectionLost) {
        connectionLost = true;
      } else if (connectionLost && !(state is cb.ConnectionLost)) {
        connectionLost = false;
      }
    });
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
          switch (await repository.prolongToken()) {
            case AuthResult.Ok:
              final InitData initData = await initMain();
              yield Authenticated(initData);
              break;
            case AuthResult.NetworkError:
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
      if (connectionLost) return;
      yield Authenticating();
      final res = await repository.authenticate(
        username: event.username,
        password: event.password,
      );
      switch (res) {
        case AuthResult.WrongCredentials:
          yield WrongCredentials(
            username: event.username,
            password: event.password,
          );
          break;
        case AuthResult.NetworkError:
          yield AuthenticationError(
            username: event.username,
            password: event.password,
          );
          break;
        default:
          final InitData initData = await initMain();
          yield Authenticated(initData);
      }
    } else if (event is WrongAuthCredentials) {
      yield WrongCredentials(
        username: tempCreds['username'],
        password: tempCreds['password'],
      );
      tempCreds = {};
    } else if (event is ResetAuthentication) {
      if (event.message == null) {
        await repository.logout();
      } else {
        repository.clean();
      }
      yield Unauthenticated(message: event.message);
    } else if (event is RegistrationInit) {
      yield Registration('https://console.twake.app/signup');
    } else if (event is ResetPassword) {
      yield PasswordReset('https://console.twake.app/password-recovery');
    } else if (event is ValidateHost) {
      yield HostValidation(event.host);
      Api.host = event.host;
      final valid = await repository.getAuthMode();
      // final host = '${event.host}';
      if (!valid) {
        yield HostInvalid(event.host);
        yield HostValidation(event.host);
      } else {
        yield HostValidated(event.host);
      }
    } else if (event is ResetHost) {
      await repository.clean();
      yield HostReset();
    }
  }

  void resetAuthentication() {
    this.add(ResetAuthentication(message: 'Session has expired'));
  }

  void resetHost() {
    this.add(ResetHost());
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}

/// EXAMPLE OF CONSOLE AUTH RESPONSE
// {
// "ready": true,
// "auth_mode": [
// "console"
// ],
// "auth": {
// "console": {
// "use": true,
// "account_management_url": "https://console.qa.twake.app/profile",
// "company_management_url": "https://console.qa.twake.app/company",
// "collaborators_management_url": "https://console.qa.twake.app/company/users",
// "mobile_endpoint_url": "https://beta.twake.app/ajax/users/console/openid?mobile=1"
// }
// },
// "version": {
// "current": "2020.Q4.135",
// "minimal": {
// "web": "2020.Q4.135",
// "mobile": "2020.Q4.135"
// }
// },
// "elastic_search_available": true,
// "help_link": "https://go.crisp.chat/chat/embed/?website_id=9ef1628b-1730-4044-b779-72ca48893161",
// "branding": {
// "name": "Twake",
// "enable_newsletter": false
// }
// }
