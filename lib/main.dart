import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/di/home_binding.dart';
import 'package:twake/routing/route_pages.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/init_service.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/widgets/common/pull_to_refresh_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken().onError((e, _) async {
    Logger().e('Error occurred when requesting Firebase Messaging token\n$e');
  });

  await InitService.preAuthenticationInit();

  await dotenv.load(fileName: ".env");

  runApp(RefreshConfiguration(
    headerBuilder: () => PullToRefreshHeader(
        height: 100,
        padding: EdgeInsets.only(
            top:
                22)), // Configure the default header indicator. If you have the same header indicator for each page, you need to set this
    headerTriggerDistance: 80.0, // header trigger refresh trigger distance
    maxUnderScrollExtent: 0, // Maximum dragging range at the bottom
    enableScrollWhenRefreshCompleted:
        true, //This property is incompatible with PageView and TabBarView. If you need TabBarView to slide left and right, you need to set it to true.
    enableLoadingWhenFailed:
        true, //In the case of load failure, users can still trigger more loads by gesture pull-up.
    enableBallisticLoad: true, // trigger load more by BallisticScrollActivity

    child: GetMaterialApp(
      theme: StylesConfig.lightTheme,
      title: 'Twake',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('fr'),
        Locale('vi'),
      ],
      locale: Locale('en'),
      getPages: routePages,
      initialRoute: RoutePaths.initial,
      initialBinding: HomeBinding(),
    ),
  ));
}
