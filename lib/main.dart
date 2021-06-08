import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/styles_config.dart';
import 'package:twake/di/home_binding.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/routing/route_pages.dart';
import 'package:twake/services/init_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await InitService.preAuthenticationInit();

  runApp(GetMaterialApp(home: TwakeMobileApp(), getPages: routePages, initialBinding: HomeBinding(),));
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
              home: InitialPage());
        },
      ),
    );
  }
}
