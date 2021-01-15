import 'dart:convert' show jsonDecode;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebAuthPage extends StatefulWidget {
  WebAuthPage() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  _WebAuthPageState createState() => _WebAuthPageState();
}

class _WebAuthPageState extends State<WebAuthPage> {
  WebViewController webViewController;
  final twakeConsole = 'https://beta.twake.app/login';
  bool hasMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: (ctrl) => webViewController = ctrl,
        navigationDelegate: (r) async {
          Logger().d('URL IS: ' + r.url);
          // if (r.url.contains('//oauth2')) {
          // return NavigationDecision.prevent;
          // }
          return NavigationDecision.navigate;
        },
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: twakeConsole,
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'AuthData',
              onMessageReceived: (jsmsg) async {
                await CookieManager().clearCookies();
                if (hasMessage) return;
                hasMessage = true;
                BlocProvider.of<AuthBloc>(context).add(
                  SetAuthData(jsonDecode(jsmsg.message)),
                );
                Logger().d('GOT DATA FROM WEBVIEW: ' + jsmsg.message);
                webViewController.clearCache();
              }),
        ]),
      ),
    );
  }
}
