import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class StylesConfig {
  // static const Color accentColor = Color.fromRGBO(198, 46, 222, 1.0);
  // static const Color lightAppColor = Colors.white;

  StylesConfig._();

  static const Color subTitleTextColor = Color(0xFF9F988F);
  static const accentColorRGB = Color.fromRGBO(131, 125, 255, 1);
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    accentColor: accentColorRGB,
    // brightness: Brightness.light,
    textTheme: lightTextTheme,
    useTextSelectionTheme: true,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0xff837cfe),
      // selectionColor: darkPrimarySwatchColor,
      // selectionHandleColor: darkPrimarySwatchColor,
    ),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 0.0,
      brightness: Brightness.light,
    ),
    // fontFamily: 'PT',
  );

  /// For future use
  // static final ThemeData darkTheme = ThemeData(
  // primaryColor: lightAppColor,
  // brightness: Brightness.dark,
  // textTheme: darkTextTheme,
  // );

  static final TextTheme lightTextTheme = TextTheme(
    headline1: _headline1,
    headline2: _headline2,
    headline3: _headline3,
    headline4: _headline4,
    headline5: _headline5,
    headline6: _headline6,
    bodyText1: _bodyText1,
    bodyText2: _bodyText2,
    subtitle1: _subtitle1,
    subtitle2: _subtitle2,
    button: _button,
  );

  static final TextStyle _headline6 = TextStyle(
    color: Colors.black87,
    fontWeight: FontWeight.w500,
    fontSize: Dim.tm2(decimal: .9),
  );

  static final TextStyle _headline2 = TextStyle(
    color: Colors.black,
    fontSize: Dim.tm2(decimal: .9),
  );

  static final TextStyle _headline1 = TextStyle(
      color: accentColorRGB,
      fontSize: Dim.tm4(decimal: .9),
      fontWeight: FontWeight.normal);

  static final TextStyle _headline5 = TextStyle(
    color: Colors.black87,
    fontSize: Dim.tm3(decimal: -.2),
    fontWeight: FontWeight.bold,
  );

  static final TextStyle _subtitle1 = TextStyle(
    color: Colors.black,
    fontSize: Dim.tm2(decimal: -.3),
  );
  static final TextStyle _subtitle2 = TextStyle(
    color: subTitleTextColor,
    fontSize: Dim.tm2(decimal: -.5),
  );

  static final TextStyle _button = TextStyle(
    color: Colors.white,
    fontSize: Dim.tm2(decimal: .7),
  );

  static final TextStyle _headline4 = TextStyle(
    color: accentColorRGB,
    fontSize: Dim.tm2(decimal: .3),
  );

  static final TextStyle _headline3 = TextStyle(
    color: Colors.black,
    fontSize: Dim.tm3(decimal: .3),
    fontWeight: FontWeight.bold,
  );

  static final TextStyle _bodyText1 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: Dim.tm2(decimal: .5),
  );

  static final TextStyle _bodyText2 = TextStyle(
    color: Colors.black87,
    fontSize: Dim.tm2(),
  );

  static final miniPurple =
      TextStyle(color: accentColorRGB, fontSize: Dim.tm2(decimal: .15));

  /// For future use in dark theme
  // static final TextStyle _titleDark = _titleLight.copyWith(color: Colors.white);
//
  // static final TextStyle _subTitleDark =
  // _subTitleLight.copyWith(color: Colors.white70);
//
  // static final TextStyle _buttonDark =
  // _buttonLight.copyWith(color: Colors.black);
//
  // static final TextStyle _greetingDark =
  // _greetingLight.copyWith(color: Colors.black);
//
  // static final TextStyle _searchDark =
  // _searchDark.copyWith(color: Colors.black);
//
  // static final TextStyle _selectedTabDark =
  // _selectedTabDark.copyWith(color: Colors.white);
//
  // static final TextStyle _unSelectedTabDark =
  // _selectedTabDark.copyWith(color: Colors.white70);
//
  /// This class should not be instantiated !!!
}
