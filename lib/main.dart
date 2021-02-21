import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc/auth_bloc.dart';
import 'package:twake/blocs/connection_bloc/connection_bloc.dart' as cb;
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/repositories/configuration_repository.dart';
import 'package:twake/services/init.dart';
import 'package:twake/utils/sentry.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final AuthRepository repository = await initAuth();
    final ConfigurationRepository configurationRepository = await ConfigurationRepository.load();
    cb.ConnectionState connectionState;
    final res = await Connectivity().checkConnectivity();
    if (res == ConnectivityResult.none) {
      connectionState = cb.ConnectionLost('');
    } else if (res == ConnectivityResult.wifi) {
      connectionState = cb.ConnectionWifi();
    } else if (res == ConnectivityResult.mobile) {
      connectionState = cb.ConnectionCellular();
    }
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    FlutterError.onError = (FlutterErrorDetails details) {
      if (isInDebugMode) {
        // In development mode, simply print to console.
        FlutterError.dumpErrorToConsole(details);
      } else {
        // In production mode, report to the application zone to report to
        // Sentry.
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };
    runApp(TwakeMobileApp(repository, configurationRepository, connectionState,));
  }, (Object error, StackTrace stackTrace) {
    // Whenever an error occurs, call the `reportError` function. This sends
    // Dart errors to the dev console or Sentry depending on the environment.
    reportError(error, stackTrace);
  });
}

class TwakeMobileApp extends StatelessWidget {
  final AuthRepository repository;
  final ConfigurationRepository configurationRepository;
  final cb.ConnectionState connectionState;

  TwakeMobileApp(
    this.repository,
    this.configurationRepository,
    this.connectionState,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => OrientationBuilder(
        builder: (context, orientation) {
          Dim.init(constraints, orientation);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: StylesConfig.lightTheme,
            title: 'Twake',
            home: MultiBlocProvider(
              providers: [
                BlocProvider<cb.ConnectionBloc>(
                  create: (ctx) => cb.ConnectionBloc(connectionState),
                  lazy: false,
                ),
                BlocProvider<AuthBloc>(
                  create: (ctx) =>
                      AuthBloc(repository, ctx.read<cb.ConnectionBloc>()),
                  lazy: false,
                ),
              ],
              child: InitialPage(),
            ),
          );
        },
      ),
    );
  }
}
