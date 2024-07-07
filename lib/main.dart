import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/di/home_binding.dart';
import 'package:twake/di/main_bindings.dart';
import 'package:twake/di/remote_binding.dart';
import 'package:twake/repositories/language_repository.dart';
import 'package:twake/repositories/theme_repository.dart';
import 'package:twake/routing/route_pages.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/platform_detection.dart';
import 'package:twake/widgets/common/pull_to_refresh_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".firebase.env");
  try {
    String apiKey = dotenv.get('API_KEY');
    String appId = dotenv.get('APP_ID');
    String messagingSenderId = dotenv.get('MESSAGE_SENDER_ID');
    String projectId = dotenv.get('PROJECT_ID');
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app' && Firebase.apps.isNotEmpty) {
      Logger().log(Level.info, 'Firebase initialized from persisted instance');
    } else {
      throw e;
    }
  } catch (e) {
    Logger().e('Error occurred while initializing firebase:\n$e');
  }

  FirebaseMessaging.instance.getToken().onError((e, _) async {
    Logger().e('Error occurred when requesting Firebase Messaging token\n$e');
  });

  await MainBindings().dependencies();

  final initService = Get.find<InitService>();
  await initService.preloadGlobals();

  RemoteBindings().dependencies();

  await dotenv.load(fileName: ".env");
  //TODO Do refactoring when UserProfile API will be ready, remove get_storage dep
  await GetStorage.init();

  final language = await Get.find<LanguageRepository>().getLanguage();
  final themeMode = await Get.find<ThemeRepository>().getInitTheme();

  if (PlatformDetection.isMobileSupported()) {
    await FlutterDownloader.initialize(debug: kDebugMode);
  }

  runApp(
    RefreshConfiguration(
      headerBuilder: () =>
          PullToRefreshHeader(height: 100, padding: EdgeInsets.only(top: 22)),
      // Configure the default header indicator. If you have the same header indicator for each page, you need to set this
      headerTriggerDistance: 80.0,
      // header trigger refresh trigger distance
      maxUnderScrollExtent: 0,
      // Maximum dragging range at the bottom
      enableScrollWhenRefreshCompleted: true,
      //This property is incompatible with PageView and TabBarView. If you need TabBarView to slide left and right, you need to set it to true.
      enableLoadingWhenFailed: true,
      //In the case of load failure, users can still trigger more loads by gesture pull-up.
      enableBallisticLoad: true,
      // trigger load more by BallisticScrollActivity

      child: GetMaterialApp(
        theme: StylesConfig.lightTheme,
        darkTheme: StylesConfig.darkTheme,
        themeMode: themeMode,
        title: 'Twake',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('fr'),
          const Locale('fi'),
          const Locale('es'),
          const Locale('it'),
          const Locale('de'),
          const Locale('ru'),
          const Locale('zh'),
          const Locale('nb'),
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          const Locale.fromSubtags(languageCode: 'nb', scriptCode: 'NO'),
        ],
        locale: Locale(language),
        getPages: routePages,
        initialRoute: RoutePaths.initial,
        initialBinding: HomeBinding(),
      ),
    ),
  );
}
