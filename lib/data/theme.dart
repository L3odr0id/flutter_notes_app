import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TupleTheme {
  String name;
  ThemeData theme;

  TupleTheme(String str, ThemeData theme) {
    name = str;
    this.theme = theme;
  }
}
// ignore: non_constant_identifier_names
final List<TupleTheme> ThemeNames = [
  TupleTheme("dark", appThemeDark),
  TupleTheme("light", appThemeLight),
];

Future<TupleTheme> getCurrentTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String themeName = prefs.getString('theme');
  print(themeName);
  if (themeName == null)
    return ThemeNames[0];
  else {
    for (var i = 0; i < ThemeNames.length; i++) {
      if (ThemeNames[i].name == themeName) return ThemeNames[i];
    }
  }
  return ThemeNames[0];
}

// For dark
Color background = Color.fromARGB(255, 40, 42, 54);
Color foreground = Color.fromARGB(255, 248, 248, 242);

final ThemeData appThemeLight = ThemeData.light().copyWith(primaryColor: background);

final ThemeData appThemeDark = ThemeData.dark().copyWith(
    primaryColor: foreground,
    accentColor: Colors.green,
    backgroundColor: background);

final ThemeData appThemeExperimental = ThemeData.dark().copyWith(
    primaryColor: foreground,
    accentColor: Colors.yellow,
    backgroundColor: background);
