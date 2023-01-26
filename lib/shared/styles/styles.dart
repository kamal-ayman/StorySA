import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

ThemeData lightTheme = ThemeData(
  
  // splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  textTheme: const TextTheme(
    titleSmall: TextStyle(),
    titleLarge: TextStyle(),
  ).apply(
    displayColor: Colors.white,
    bodyColor: Colors.white,
    decorationColor: Colors.white,
  ),
  primaryIconTheme: IconThemeData(
    color: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    backgroundColor: Color(0xff008066),
    systemOverlayStyle: SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xff008066),
      systemNavigationBarDividerColor: Color(0xff008066),
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  // splashColor: Colors.transparent,
  // splashFactory: ,
  splashFactory: NoSplash.splashFactory,
  primaryIconTheme: IconThemeData(
    color: Colors.white,
  ),
  textTheme: const TextTheme(
    titleSmall: TextStyle(),
    titleLarge: TextStyle(),
  ).apply(
    displayColor: Colors.white,
    bodyColor: Colors.white,
    decorationColor: Colors.white,
  ),
  accentColor: Colors.green,
  primarySwatch: Colors.green,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white70),
    systemOverlayStyle: SystemUiOverlayStyle(
      systemNavigationBarColor: darkColorDarkTheme,
      systemNavigationBarDividerColor: darkColorDarkTheme,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    foregroundColor: lightColorDarkTheme,
    backgroundColor: darkColorDarkTheme,
  ),
  scaffoldBackgroundColor: const Color(0xff0f1c1e),
  dialogTheme: const DialogTheme(
    contentTextStyle: TextStyle(
      color: Colors.white,
    ),
    backgroundColor: Color(0xff0f1c1e),
    titleTextStyle: TextStyle(
      color: Colors.white,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      color: Colors.white,
    ),
    border: const OutlineInputBorder(),
    filled: true,
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.green,
      ),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
      ),
    ),
    fillColor: Colors.white.withOpacity(.09),
    // prefixIconColor: Colors.green,
  ),
  backgroundColor: const Color(0xff0f1c1e),
);
