import 'package:flutter/material.dart';

Color background = Color.fromARGB(255, 40, 42, 54);
Color foreground = Color.fromARGB(255, 248, 248, 242);

ThemeData appThemeLight =  ThemeData.light().copyWith(
    primaryColor: background);

ThemeData appThemeDark = ThemeData.dark().copyWith(
    primaryColor: foreground,
    toggleableActiveColor: background,
    accentColor: background,
    buttonColor: background,
    textSelectionColor: background,
    textSelectionHandleColor: background,
    backgroundColor: background);