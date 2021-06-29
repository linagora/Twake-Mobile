import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/di/home_binding.dart';
import 'package:twake/routing/route_pages.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/init_service.dart';
import 'package:twake/services/service_bundle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken().onError((e, _) async {
    Logger().e('Error occurred when requesting Firebase Messaging token\n$e');
  });

  await InitService.preAuthenticationInit();

  runApp(GetMaterialApp(
    theme: StylesConfig.lightTheme,
    title: 'Twake',
    getPages: routePages,
    initialRoute: RoutePaths.initial,
    initialBinding: HomeBinding(),
  ));
}
