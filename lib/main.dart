import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/di/home_binding.dart';
import 'package:twake/routing/route_pages.dart';
import 'package:twake/services/init_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await InitService.preAuthenticationInit();

  runApp(GetMaterialApp(
    theme: StylesConfig.lightTheme,
    title: 'Twake',
    getPages: routePages,
    initialRoute: '/initial',
    initialBinding: HomeBinding(),
  ));
}
