import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

//TODO Do refactoring when UserProfile API will be ready, remove get_storage dep
const List<String> themeList = ["Light", "Dark", "System"];

class ThemeRepository {
  final getStorage = GetStorage();

  Future<String> getTheme() async {
    return getStorage.read('theme') ?? themeList[2];
  }

  ThemeMode getThemeMode({required String theme}) {
    switch (theme) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  Future<ThemeMode> getInitTheme() async {
    final theme = await getTheme();

    return getThemeMode(theme: theme);
  }
}
