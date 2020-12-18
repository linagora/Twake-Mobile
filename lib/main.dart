import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/pages/initial_page.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/init.dart';

void main() async {
  /// Wait for flutter to initialize
  WidgetsFlutterBinding.ensureInitialized();

  /// Disable landscape mode
  final AuthRepository repository = await init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(TwakeMobileApp(repository)));
}

class TwakeMobileApp extends StatelessWidget {
  final AuthRepository repository;
  TwakeMobileApp(this.repository);
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
          Dim.init(constraints, orientation);
          return MaterialApp(
            home: BlocProvider(
              create: (ctx) => AuthBloc(repository),
              child: InitialPage(),
            ),
          );
        },
      ),
    );
  }
}
