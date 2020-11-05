import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/providers/companies_provider.dart';
import 'package:twake_mobile/providers/init_provider.dart';
import 'package:twake_mobile/providers/user_provider.dart';
import 'package:twake_mobile/screens/auth_screen.dart';
import 'package:twake_mobile/screens/companies_list_screen.dart';

void main() {
  runApp(TwakeMobileApp());
}

class TwakeMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => OrientationBuilder(
        builder: (context, orientation) {
          /// Here we initialize the size configuration, to get access
          /// to scaling multipliers accross the rest of the app.
          /// If screen orientation changes, OrientationBuilder will reinitialize
          /// the configuration again, so other widgets can make use
          /// of new values.
          DimensionsConfig().init(constraints, orientation);
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<InitProvider>(
                create: (ctx) {
                  return InitProvider()..init();
                },
              ),
              ChangeNotifierProxyProvider<InitProvider, UserProvider>(
                create: (ctx) {
                  var data =
                      Provider.of<InitProvider>(ctx, listen: false).userData;
                  return UserProvider()..loadUser(data);
                },
                update: (ctx, init, user) => user..loadUser(init.userData),
              ),
              ChangeNotifierProxyProvider<InitProvider, CompaniesProvider>(
                create: (ctx) {
                  var data =
                      Provider.of<InitProvider>(ctx, listen: false).companies;
                  return CompaniesProvider()..loadCompanies(data);
                },
                update: (ctx, init, companies) =>
                    companies..loadCompanies(init.companies),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Twake',
              theme: StylesConfig.lightTheme,
              home: AuthScreen(),
              routes: {
                AuthScreen.route: (BuildContext _) => AuthScreen(),
                CompaniesListScreen.route: (BuildContext _) =>
                    CompaniesListScreen(),
              },
            ),
          );
        },
      ),
    );
  }
}
