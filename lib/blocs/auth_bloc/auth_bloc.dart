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

  cb.ConnectionBloc connectionBloc;
  StreamSubscription subscription;

  bool connectionLost = false;
  final twakeConsole =
      'https://beta.twake.app/ajax/users/console/openid?mobile=1';
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
    webView = HeadlessInAppWebView(
      initialUrl: twakeConsole,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          cacheEnabled: false,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
      ),
      onConsoleMessage: (ctrl, msg) => print('CONSOLEJS: $msg'),
      onLoadStop: (ctrl, url) async {
        print('URL: $url');
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
            print('NO TOKEN AND USERNAME');
            ctrl.loadUrl(url: twakeConsole);
            this.add(WrongAuthCredentials());
            return;
          }
          this.add(
            SetAuthData(qp),
          );
          ctrl.clearCache();
          await CookieManager().deleteAllCookies();
        }
      },
      onLoadError: (ctr, a, b, c) {
        print('WEBVIEW LOAD ERROR: $a, $b, $c');
      },
      onWebViewCreated: (ctrl) {
        print('CREATED WEBVIEW');
      },
    );
    CookieManager.instance().deleteAllCookies();
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
              webView.run();
          }
          break;
        case TokenStatus.BothExpired:
          yield Unauthenticated(message: 'Session expired');
          webView.run();
      }
    } else if (event is Authenticate) {
      if (connectionLost) return;
      yield Authenticating();
      print('CURRENT PAGE ${await webView.webViewController.getUrl()}');
      await webView.webViewController.evaluateJavascript(
          source:
              '''!function(l,p){function f(){document.getElementById("userfield").value=l,document.getElementById("passwordfield").value=p,document.getElementById("lform").submit()}"complete"===document.readyState||"interactive"===document.readyState?setTimeout(f,1):document.addEventListener("DOMContentLoaded",f)}("${event.username}","${event.password}");''');
    } else if (event is SetAuthData) {
      yield Authenticating();
      await repository.setAuthData(event.authData);
      final InitData initData = await initMain();
      yield Authenticated(initData);
      _prevUrl = '';
      webView.dispose();
    } else if (event is WrongAuthCredentials) {
      yield WrongCredentials();
      runWebView();
    } else if (event is ResetAuthentication) {
      if (event.message == null) {
        repository.fullClean();
      } else {
        repository.clean();
      }
      yield Unauthenticated(message: event.message);
      runWebView();
    } else if (event is RegistrationInit) {
      yield Registration('https://console.twake.app/signup');
    } else if (event is ResetPassword) {
      yield PasswordReset('https://console.twake.app/password-recovery');
    }
  }

  Future<void> runWebView() async {
    await CookieManager.instance().deleteAllCookies();
    _prevUrl = '';
    await webView.dispose();
    webView.run();
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
