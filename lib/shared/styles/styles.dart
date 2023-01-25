import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightTheme = ThemeData(
  // splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
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
  appBarTheme: const AppBarTheme(
iconTheme: IconThemeData(
  color: Colors.white70
),
    systemOverlayStyle: SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xff1e2d31),
      systemNavigationBarDividerColor: Color(0xff1e2d31),
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    foregroundColor: Color(0xff83979d),
    backgroundColor: Color(0xff1e2d31),
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
  textTheme: TextTheme(
  ),
  backgroundColor: const Color(0xff0f1c1e),
);
