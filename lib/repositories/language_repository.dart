import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class LanguageRepository {
  LanguageRepository();
  final _locale = Locale("en");

  Locale get locale {
    String defaultLocale = Platform.localeName;
    List<Locale> systemLocales1 = WidgetsBinding.instance!.window.locales;
    List<Locale> systemLocales2 = window.locales;

    print(defaultLocale);
    print(systemLocales1);
    print(systemLocales2);
    if (defaultLocale == "es_US") {
      defaultLocale = "es";
    }

    final _locale = Locale(defaultLocale);
    return _locale;
  }

  Locale getLanguage() {
    final String defaultLocale = Platform.localeName;

    return _locale;
  }
}
