import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:twake_mobile/screens/auth_screen.dart';

void main() {
  runApp(TwakeMobileApp());
}

class TwakeMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Twake',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(126, 120, 251, 1.0),
        accentColor: Colors.purpleAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (BuildContext context, Widget widget) =>
          ResponsiveWrapper.builder(
        widget,
        defaultScale: true,
        maxWidth: 1920,
        minWidth: 480,
        breakpoints: [
          ResponsiveBreakpoint.resize(480, name: MOBILE),
          ResponsiveBreakpoint.autoScale(800, name: TABLET),
        ],
      ),
      home: AuthScreen(),
    );
  }
}
