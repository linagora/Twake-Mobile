import 'package:flutter/material.dart';
import 'package:twake_mobile/screens/auth_screen.dart';
import 'package:twake_mobile/screens/companies_list_screen.dart';

void main() {
  runApp(TwakeMobileApp());
}

class TwakeMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Twake',
        theme: ThemeData(
          primaryColor: Color.fromRGBO(126, 120, 251, 1.0),
          accentColor: Colors.purpleAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthScreen(),
        routes: {
          AuthScreen.route: (BuildContext _) => AuthScreen(),
          CompaniesListScreen.route: (BuildContext _) => CompaniesListScreen(),
        },
      ),
    );
  }
}
