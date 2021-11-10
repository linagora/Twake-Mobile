import 'dart:io';
import 'dart:ui';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/storage_service.dart';

//TODO before the build, update the list of translated languages using weblate
const List<String> translatedLanguages = ["en", "es"];

class LanguageRepository {
  final _storage = StorageService.instance;
  LanguageRepository();

  // To get a list of available languages from the device
  // List<Locale> systemLocales = WidgetsBinding.instance!.window.locales;
  // List<Locale> systemLocales = window.locales;

  Locale get devLocale {
    String deviceLanguage = Platform.localeName;

    final String language = translatedLanguages.firstWhere(
        (language) => language == deviceLanguage.replaceAll("_US", ""),
        orElse: () => translatedLanguages[0]);

    return Locale(language);
  }

  List<String> get languages {
    return translatedLanguages;
  }

  String getDeviceLanguage() {
    String deviceLanguage = Platform.localeName;

    final String language = translatedLanguages.firstWhere(
        (language) => language == deviceLanguage.replaceAll("_US", ""),
        orElse: () => translatedLanguages[0]);

    return language;
  }

  Future<String> getLanguageFromDB() async {
    if (Globals.instance.userId != null) {
      final language = await _storage.select(
          table: Table.account,
          columns: ["language"],
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);
      return language[0]["language"].toString();
    } else {
      return 'notFound';
    }
  }

  Future<String> getLanguage() async {
    final deviceLanguage = getDeviceLanguage();
    final dbLanguage = await getLanguageFromDB();

    final String language = translatedLanguages.firstWhere(
        (language) => language == dbLanguage,
        orElse: () => 'notFound');

    if (language != 'notFound') {
      return language;
    } else {
      return deviceLanguage;
    }
  }

  Future<void> updateLanguageDB({required String language}) async {
    _storage.update(
        table: Table.account,
        values: {'language': language},
        where: "id = ?",
        whereArgs: [Globals.instance.userId]);
  }
}
