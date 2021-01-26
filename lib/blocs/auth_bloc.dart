import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/auth_event.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/init.dart';
import 'package:twake/states/auth_state.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

export 'package:twake/events/auth_event.dart';
export 'package:twake/states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  HeadlessInAppWebView webView;
  final twakeConsole =
      'https://beta.twake.app/ajax/users/console/openid?mobile=1';
  AuthBloc(this.repository) : super(AuthInitializing()) {
    Api().resetAuthentication = resetAuthentication;
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
        if (url.contains('redirect_to_app')) {
          final qp = Uri.parse(url).queryParameters;
          // Logger().d('PARAMS: $qp');
          if (qp['token'] == null || qp['username'] == null) {
            print('NO TOKEN AND USERNAME');
            ctrl.loadUrl(url: twakeConsole);
            return;
          }
          this.add(
            SetAuthData(qp),
          );
          ctrl.clearCache();
          await CookieManager().deleteAllCookies();
        }
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
          // final InitData initData = await initMain();
          // yield Authenticated(initData);
          // break;
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
      yield Authenticating();
      print('CURRENT PAGE ${await webView.webViewController.getUrl()}');
      print(await webView.webViewController.evaluateJavascript(
          source:
              '''!function(l,p){function f(){document.getElementById("userfield").value=l,document.getElementById("passwordfield").value=p,document.getElementById("lform").submit()}"complete"===document.readyState||"interactive"===document.readyState?setTimeout(f,1):document.addEventListener("DOMContentLoaded",f)}("${event.username}","${event.password}");'''));
      // final result = await repository.authenticate(
      // username: event.username,
      // password: event.password,
      // );
      // if (result == AuthResult.WrongCredentials) {
      // yield Unauthenticated(message: 'Wrong credentials');
      // } else if (result == AuthResult.NetworkError) {
      // yield AuthenticationError();
      // } else {
      // final InitData initData = await initMain();
      // yield Authenticated(initData);
      // }
    } else if (event is SetAuthData) {
      yield Authenticating();
      await repository.setAuthData(event.authData);
      final InitData initData = await initMain();
      yield Authenticated(initData);
      webView.dispose();
    } else if (event is ResetAuthentication) {
      if (event.message == null) {
        repository.fullClean();
      } else {
        repository.clean();
      }
      yield Unauthenticated(message: event.message);
      await CookieManager.instance().deleteAllCookies();
      await webView.dispose();
      webView.run();
    }
  }

  void resetAuthentication() {
    this.add(ResetAuthentication(message: 'Session has expired'));
  }

  @override
  Future<void> close() {
    webView.dispose();
    return super.close();
  }
}
