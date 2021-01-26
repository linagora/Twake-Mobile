import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/blocs/connection_bloc.dart' as cb;
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository repository = await initAuth();
  cb.ConnectionState connectionState;
  final res = await Connectivity().checkConnectivity();
  if (res == ConnectivityResult.none) {
    connectionState = cb.ConnectionLost('');
  } else if (res == ConnectivityResult.wifi) {
    connectionState = cb.ConnectionWifi();
  } else if (res == ConnectivityResult.mobile) {
    connectionState = cb.ConnectionCellular();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(TwakeMobileApp(repository, connectionState)));
}

class TwakeMobileApp extends StatelessWidget {
  final AuthRepository repository;
  final cb.ConnectionState connectionState;
  TwakeMobileApp(this.repository, this.connectionState);
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
