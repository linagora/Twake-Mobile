import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const route = '/twake/web/view';
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final link = ModalRoute.of(context).settings.arguments as String;
    return SafeArea(
      child: WebView(
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: link,
      ),
    );
  }
}
