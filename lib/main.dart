import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/services/init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository repository = await initAuth();
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
          Dim.init(constraints, orientation);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: StylesConfig.lightTheme,
            title: 'Twake',
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
