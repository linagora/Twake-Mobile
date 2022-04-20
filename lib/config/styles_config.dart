import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class StylesConfig {
  StylesConfig._();

  static const Color subTitleTextColor = Color(0xFF9F988F);
  static const accentColorRGB = Color.fromRGBO(131, 125, 255, 1);

  static const ColorScheme darkThemeColorScheme = ColorScheme(
    primary: Color(0xFF19191A),
    primaryContainer: Colors.white,
    secondary: Color(0xFF76787A),
    secondaryContainer: Color(0xFF2C2D2F),
    surface: Color(0xFF276CFF),
    background: Color(0xFF424242),
    error: Color(0xFFFF3347),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.black,
    brightness: Brightness.dark,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    colorScheme: darkThemeColorScheme,
    fontFamily: fontFamilyByPlatform(),
    textTheme: darkTextTheme,
    scaffoldBackgroundColor: Color(0xFF19191A),
    iconTheme: IconThemeData(color: Colors.white),
    appBarTheme: AppBarTheme(color: Color(0xFF19191A)),
    brightness: Brightness.dark,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF007AFF),
        selectionColor: Color(0xFF007AFF).withOpacity(0.84),
        selectionHandleColor: Color(0xFF007AFF).withOpacity(0.84)),
  );
  static const ColorScheme lightThemeColorScheme = ColorScheme(
    primary: Color(0xFFD2D2D2),
    primaryContainer: Colors.black,
    secondary: Color(0xFF818C99),
    secondaryContainer: Color(0xFFF5F5F5),
    surface: Color(0xFF007AFF),
    background: Color(0xFFD2D2D2),
    error: Color(0xFFFF3347),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white,
    colorScheme: lightThemeColorScheme,
    fontFamily: fontFamilyByPlatform(),
    textTheme: lightTextTheme,
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
    iconTheme: IconThemeData(color: Color(0xFFEBEDF0)),
    appBarTheme: AppBarTheme(color: Color(0xFFEBEDF0)),
    brightness: Brightness.light,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF007AFF),
        selectionColor: Color(0xFF007AFF).withOpacity(0.84),
        selectionHandleColor: Color(0xFF007AFF).withOpacity(0.84)),
  );

  static final TextTheme lightTextTheme = TextTheme(
    headline1: _lightHeadline1,
    headline2: _lightHeadline2,
    headline3: _lightHeadline3,
    headline4: _lightHeadline4,
    headline5: _lightHeadline5,
    bodyText1: _lightBodyText1,
    subtitle1: _lightSubtitle1,
  );
  static final TextTheme darkTextTheme = TextTheme(
    headline1: _darkHeadline1,
    headline2: _darkHeadline2,
    headline3: _darkHeadline3,
    headline4: _darkHeadline4,
    headline5: _darkHeadline5,
    bodyText1: _darkbodyText1,
    subtitle1: _darksubtitle1,
  );

  static final TextStyle _darkHeadline1 = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _darkHeadline2 = TextStyle(
      color: Color(0xFFA7A8AC),
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _darkHeadline3 = TextStyle(
      color: Color(0xFF76787A),
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _darkHeadline4 = TextStyle(
      color: Color(0xFF276CFF),
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamilyByPlatform());
  static final TextStyle _darkHeadline5 = TextStyle(
      color: Color(0xFFFF3347),
      fontSize: 17.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _darksubtitle1 = TextStyle(
      color: Colors.black,
      fontSize: 8.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _darkbodyText1 = TextStyle(
      color: Color(0xFF8F9498),
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightHeadline1 = TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightHeadline2 = TextStyle(
      color: Color(0xFF5C6268),
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightHeadline3 = TextStyle(
      color: Color(0xFF818C99),
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightHeadline4 = TextStyle(
      color: Color(0xFF007AFF),
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightHeadline5 = TextStyle(
      color: Color(0xFFFF3347),
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightSubtitle1 = TextStyle(
      color: Colors.black,
      fontSize: 8.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final TextStyle _lightBodyText1 = TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      fontFamily: fontFamilyByPlatform());

  static final miniPurple = TextStyle(
    color: Color(0xff837DFF),
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  );

  static final disabled = TextStyle(
    color: Color(0xff696969),
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  );
  static final signupAgreement = TextStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.normal,
      color: Color(0xFF969698),
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted);
//TextStyle(color: accentColorRGB, fontSize: Dim.tm2(decimal: .15));

  static final commonTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamilyByPlatform());

  static final commonBoxDecoration = BoxDecoration(
      color: Color(0xfff6f6f6),
      borderRadius: BorderRadius.all(Radius.circular(12.0)));

  static String fontFamilyByPlatform() {
    if(kIsWeb)  return 'Roboto';
    if(Platform.isIOS || Platform.isMacOS)  return 'SFPro';
    return 'Roboto';
  }
}
