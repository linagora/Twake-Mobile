import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/screens/auth_screen.dart';
import 'package:twake_mobile/screens/channels_screen.dart';
import 'package:twake_mobile/screens/companies_list_screen.dart';
import 'package:twake_mobile/screens/messages_screen.dart';
import 'package:twake_mobile/screens/workspaces_screen.dart';
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:flutter/services.dart';
// import 'package:twake_mobile/services/twake_socket.dart';

void main() {
  /// Wait for flutter to initialize
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the databse handler
  DB.init().then((_) {
    /// And disable landscape mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      /// And finally run the application
      runApp(TwakeMobileApp());
    });
  });
}

class TwakeMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TwakeApi>(
          create: (ctx) => TwakeApi(),
        ),
        ChangeNotifierProxyProvider<TwakeApi, ProfileProvider>(
          create: (ctx) {
            return ProfileProvider();
          },
          update: (ctx, api, profile) {
            if (api.isAuthorized)
              profile.loadProfile(api).catchError((error) {
                print('Error on profile update\n$error');
                Scaffold.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load user profile!'),
                  ),
                );
              });
            return profile;
          },
        ),
        ChangeNotifierProvider<ChannelsProvider>(
          create: (ctx) => ChannelsProvider(),
        ),
        ChangeNotifierProvider<MessagesProvider>(
          create: (ctx) => MessagesProvider(),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) => OrientationBuilder(
          builder: (context, orientation) {
            /// Here we initialize the size configuration, to get access
            /// to scaling multipliers accross the rest of the app.
            /// If screen orientation changes, OrientationBuilder will reinitialize
            /// the configuration again, so other widgets can make use
            /// of new values.
            Dim.init(constraints, orientation);
            final api = Provider.of<TwakeApi>(context);
            final profile = Provider.of<ProfileProvider>(context);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Twake',
              theme: StylesConfig.lightTheme,
              home: api.isAuthorized
                  ? (profile.loaded
                      ? ChannelsScreen()
                      : Center(child: CircularProgressIndicator()))
                  : AuthScreen(),
              routes: {
                AuthScreen.route: (BuildContext _) => AuthScreen(),
                CompaniesListScreen.route: (BuildContext _) =>
                    CompaniesListScreen(),
                WorkspacesScreen.route: (BuildContext _) => WorkspacesScreen(),
                ChannelsScreen.route: (BuildContext _) => ChannelsScreen(),
                MessagesScreen.route: (BuildContext _) => MessagesScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
