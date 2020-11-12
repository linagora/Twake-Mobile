import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';

class StylesConfig {
  static const Color accentColor = Color.fromRGBO(126, 120, 251, 1.0);
  static const Color lightAppColor = Colors.white;

  static const Color subTitleTextColor = Color(0xFF9F988F);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: lightAppColor,
    accentColor: accentColor,
    brightness: Brightness.light,
    textTheme: lightTextTheme,
    fontFamily: 'PT',
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: lightAppColor,
    brightness: Brightness.dark,
    textTheme: darkTextTheme,
  );

  static final TextTheme lightTextTheme = TextTheme(
    headline6: _titleLight,
    subtitle2: _subTitleLight,
    button: _buttonLight,
    headline4: _greetingLight,
    headline3: _searchLight,
    bodyText2: _selectedTabLight,
    bodyText1: _unSelectedTabLight,
    headline2: _mainTitleLight,
    headline5: _headline5,
  );

  // Almost identical to light theme, should discuss with
  // with designers about the best color pallete
  static final TextTheme darkTextTheme = TextTheme(
    headline6: _titleDark,
    subtitle2: _subTitleDark,
    button: _buttonDark,
    headline4: _greetingDark,
    headline3: _searchDark,
    bodyText2: _selectedTabDark,
    bodyText1: _unSelectedTabDark,
  );

  static final TextStyle _titleLight = TextStyle(
    color: Colors.black,
    fontSize: 3.5 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _mainTitleLight = TextStyle(
    color: Color.fromRGBO(126, 120, 251, 1),
    fontSize: 4.6 * DimensionsConfig.textMultiplier,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle _headline5 = TextStyle(
    color: Colors.white,
    fontSize: 3.3 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _subTitleLight = TextStyle(
    color: subTitleTextColor,
    fontSize: 2 * DimensionsConfig.textMultiplier,
    height: 1.5,
  );

  static final TextStyle _buttonLight = TextStyle(
    color: Colors.white,
    fontSize: 2.5 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _greetingLight = TextStyle(
    color: Color.fromRGBO(126, 120, 251, 1),
    fontSize: 2.7 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _searchLight = TextStyle(
    color: Colors.black,
    fontSize: 2.3 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _selectedTabLight = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 2 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _unSelectedTabLight = TextStyle(
    color: Colors.grey,
    fontSize: 2 * DimensionsConfig.textMultiplier,
  );

  static final TextStyle _titleDark = _titleLight.copyWith(color: Colors.white);

  static final TextStyle _subTitleDark =
      _subTitleLight.copyWith(color: Colors.white70);

  static final TextStyle _buttonDark =
      _buttonLight.copyWith(color: Colors.black);

  static final TextStyle _greetingDark =
      _greetingLight.copyWith(color: Colors.black);

  static final TextStyle _searchDark =
      _searchDark.copyWith(color: Colors.black);

  static final TextStyle _selectedTabDark =
      _selectedTabDark.copyWith(color: Colors.white);

  static final TextStyle _unSelectedTabDark =
      _selectedTabDark.copyWith(color: Colors.white70);

  /// This class should not be instantiated !!!
  StylesConfig._();
}
