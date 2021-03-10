import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/connection_bloc/connection_bloc.dart' as cb;
import 'package:twake/blocs/auth_bloc/auth_event.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/init.dart';
import 'package:twake/blocs/auth_bloc/auth_state.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

export 'package:twake/blocs/auth_bloc/auth_event.dart';
export 'package:twake/blocs/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  HeadlessInAppWebView webView;

  var tempCreds = {};
  cb.ConnectionBloc connectionBloc;
  StreamSubscription subscription;

  bool connectionLost = false;

  String _prevUrl = '';

  AuthBloc(this.repository, this.connectionBloc) : super(AuthInitializing()) {
    Api().resetAuthentication = resetAuthentication;
    subscription = connectionBloc.listen((cb.ConnectionState state) async {
      if (state is cb.ConnectionLost) {
        connectionLost = true;
      } else if (connectionLost && !(state is cb.ConnectionLost)) {
        connectionLost = false;
        runWebView();
      }
    });
    setUpWebView();
    CookieManager.instance().deleteAllCookies();
  }

  void setUpWebView([run = false]) {
    // print('AUTH MODE: ${repository.authMode}');
    // print('CONSOLE LINK: ${repository.twakeConsole}');
    if (repository.authMode == 'INTERNAL') return;
    this.webView = HeadlessInAppWebView(
      initialUrl: repository.twakeConsole,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          cacheEnabled: false,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
      ),
      // onConsoleMessage: (ctrl, msg) => print('CONSOLEJS: $msg'),
      onLoadStop: (ctrl, url) async {
        // print('URL: $url');
        if (Uri.parse(_prevUrl).path == Uri.parse(url).path) {
          this.add(WrongAuthCredentials());
          _prevUrl = '';
          return;
        }
        _prevUrl = url;
        if (url.contains('redirect_to_app')) {
          final qp = Uri.parse(url).queryParameters;
          // Logger().d('PARAMS: $qp');
          if (qp['token'] == null || qp['username'] == null) {
            repository.logger.e('NO TOKEN AND USERNAME');
            ctrl.loadUrl(url: repository.twakeConsole);
            this.add(WrongAuthCredentials());
            return;
          }
          this.add(
            SetAuthData(qp),
          );
          await ctrl.clearCache();
          await CookieManager().deleteAllCookies();
        }
      },
      onLoadError: (ctr, a, b, c) {
        print('WEBVIEW LOAD ERROR: $a, $b, $c');
      },
      onWebViewCreated: (ctrl) {
        // print('CREATED WEBVIEW');
      },
    );
    if (run) runWebView();
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
              // TODO Work out the case with absent network connection
              final InitData initData = await initMain();
              yield Authenticated(initData);
              break;
            case AuthResult.WrongCredentials:
              yield Unauthenticated();
              runWebView();
          }
          break;
        case TokenStatus.BothExpired:
          yield Unauthenticated(message: 'Session expired');
          runWebView();
      }
    } else if (event is Authenticate) {
      if (connectionLost) return;
      yield Authenticating();
      if (repository.authMode == 'INTERNAL') {
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
        return;
      }
      if (repository.authMode == 'UNKNOWN') {
        yield AuthenticationError(
          username: event.username,
          password: event.password,
        );
        return;
      } else {
        this.tempCreds['username'] = event.username;
        this.tempCreds['password'] = event.password;
      }
      // print('CURRENT PAGE ${await webView.webViewController.getUrl()}');
      final js =
          '''!function(l,p){function f(){document.getElementById("userfield").value=l,document.getElementById("passwordfield").value=p,document.getElementById("lform").submit()}"complete"===document.readyState||"interactive"===document.readyState?setTimeout(f,1):document.addEventListener("DOMContentLoaded",f)}("${event.username}","${event.password.replaceAll('"', '\\"')}");''';
      print('AUTHENTICATIG THROUGH WEBVIEW');
      await webView.webViewController.evaluateJavascript(source: js);
    } else if (event is SetAuthData) {
      print('AUTH DATA ${event.authData}');
      yield Authenticating();
      await repository.setAuthData(event.authData);
      final InitData initData = await initMain();
      yield Authenticated(initData);
      _prevUrl = '';
      webView.dispose();
    } else if (event is WrongAuthCredentials) {
      yield WrongCredentials(
        username: tempCreds['username'],
        password: tempCreds['password'],
      );
      tempCreds = {};
      runWebView();
    } else if (event is ResetAuthentication) {
      if (event.message == null) {
        repository.logout();
      } else {
        repository.clean();
      }
      yield Unauthenticated(message: event.message);
      runWebView();
    } else if (event is RegistrationInit) {
      yield Registration('https://console.twake.app/signup');
    } else if (event is ResetPassword) {
      yield PasswordReset('https://console.twake.app/password-recovery');
    } else if (event is ValidateHost) {
      Api.host = event.host;
      final result = await repository.getAuthMode();
      // final host = '${event.host}';
      if (result == 'UNKNOWN') {
        yield HostInvalid(event.host);
      } else {
        if (result == 'CONSOLE') {
          setUpWebView();
          await runWebView();
        }
        yield HostValidated(event.host);
      }
    }
  }

  Future<void> runWebView() async {
    if (repository.authMode == 'INTERNAL' || repository.authMode == 'UNKNOWN') {
      return;
    }
    await CookieManager.instance().deleteAllCookies();
    await CookieManager.instance().getCookies(url: 'auth.twake.app');
    _prevUrl = '';
    await webView.dispose();
    // print('Running webview...');
    await webView.run();
  }

  void resetAuthentication() {
    this.add(ResetAuthentication(message: 'Session has expired'));
  }

  @override
  Future<void> close() {
    webView.dispose();
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
