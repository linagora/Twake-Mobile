import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/repositories/authentication_repository.dart';
//import 'package:twake/repositories/auth_repository.dart';
//import 'package:twake/repositories/configuration_repository.dart';
//import 'package:twake/services/init.dart';
import 'package:twake/services/init_service.dart';
import 'package:twake/services/storage_service.dart';
import 'package:twake/utils/sentry.dart';

import 'blocs_new/authentication_cubit/authentication_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await InitService.preAuthenticationInit();

  runApp(TwakeMobileApp());
}

class TwakeMobileApp extends StatelessWidget {
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
            home: BlocProvider<AuthenticationCubit>(
              create: (BuildContext context) => AuthenticationCubit(),
              lazy: false,
              child: InitialPage(),
            ),
          );
        },
      ),
    );
  }
}
