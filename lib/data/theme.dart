import 'package:flutter/material.dart';

// For dark
Color background = Color.fromARGB(255, 40, 42, 54);
Color foreground = Color.fromARGB(255, 248, 248, 242);

ThemeData appThemeLight = ThemeData.light().copyWith(primaryColor: background);

ThemeData appThemeDark = ThemeData.dark().copyWith(
    primaryColor: foreground,
    accentColor: Colors.green,
    backgroundColor: background);

ThemeData appThemeExperimental = ThemeData.dark().copyWith(
    primaryColor: foreground,
    accentColor: Colors.yellow,
    backgroundColor: background);
