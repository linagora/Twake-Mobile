import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class StylesConfig {
  StylesConfig._();

  static const Color subTitleTextColor = Color(0xFF9F988F);
  static const accentColorRGB = Color.fromRGBO(131, 125, 255, 1);
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    accentColor: accentColorRGB,
    textTheme: lightTextTheme,
    useTextSelectionTheme: true,
    scaffoldBackgroundColor: Colors.white,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0xff837cfe),
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
    fontSize: Dim.tm3(decimal: .7),
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

  static final miniPurple = TextStyle(
    color: Color(0xff837DFF),
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
  );
//TextStyle(color: accentColorRGB, fontSize: Dim.tm2(decimal: .15));
}
