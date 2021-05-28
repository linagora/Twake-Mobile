/* import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc/auth_bloc.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebAuthPage extends StatefulWidget {
  final String initLink;

  WebAuthPage(this.initLink) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    CookieManager().clearCookies();
  }

  @override
  _WebAuthPageState createState() => _WebAuthPageState();
}

class _WebAuthPageState extends State<WebAuthPage> {
  WebViewController? webViewController;
  // final twakeConsole =
  // 'https://beta.twake.app/ajax/users/console/openid?mobile=1';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<AuthBloc>().add(ResetAuthentication());
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: WebView(
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            onWebViewCreated: (ctrl) => webViewController = ctrl,
            navigationDelegate: (r) async {
              Logger().d('URL IS: ' + r.url);
              if (r.url.contains('response_type=code')) {
                context.read<AuthBloc>().add(ResetAuthentication());
                // final qp = Uri.parse(r.url).queryParameters;
                // Logger().d('PARAMS: $qp');
                // if (qp['token'] == null || qp['username'] == null)
                // webViewController.loadUrl(widget.initLink);
                // BlocProvider.of<AuthBloc>(context).add(
                // SetAuthData(qp),
                // );
                // await CookieManager().clearCookies();
                return NavigationDecision.prevent;
              } else if (r.url.startsWith('mailto:')) {
                if (await canLaunch(r.url)) {
                  await launch(r.url);
                }
                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            },
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: widget.initLink,
          ),
        ),
      ),
    );
  }
}
 */
