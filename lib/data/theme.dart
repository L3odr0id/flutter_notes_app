import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores themeData and it's name
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
  TupleTheme("CYBERPUNK", cyberpunkTheme),
  TupleTheme("Dark Green elephant", appThemeDarkGreen),
  TupleTheme("Dark Yellow boy", appThemeDarkYellow),
  TupleTheme("Dark Red Alert", appThemeDarkRed),
  TupleTheme("Dark Blue death screen", appThemeDarkBlue),
  TupleTheme("Dark Purple dracula", appThemeDarkPurple),
  TupleTheme("Light Linux Mint", appThemeLightGreen),
  TupleTheme("Light Yellow lemon", appThemeLightYellow),
  TupleTheme("Light Red dragon", appThemeLightRed),
  TupleTheme("Light deep Blue", appThemeLightBlue),
  TupleTheme("Light Purple Shadow", appThemeLightPurple),
];

final TupleTheme defaultTheme =
    TupleTheme("Dark Green elephant", appThemeDarkGreen);

/// Returns name of current theme
Future<TupleTheme> getCurrentTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String themeName = prefs.getString('theme');
  print(themeName);
  if (themeName == null)
    return defaultTheme;
  else
    for (var i = 0; i < ThemeNames.length; i++)
      if (ThemeNames[i].name == themeName) return ThemeNames[i];

  return defaultTheme;
}

/// Returns themeData by name
ThemeData getThemeByName(String name) {
  for (var i = 0; i < ThemeNames.length; i++)
    if (ThemeNames[i].name == name) return ThemeNames[i].theme;
  return null;
}

// For dark
Color background = Color.fromARGB(255, 40, 42, 54);
Color foreground = Color.fromARGB(255, 248, 248, 242);

/// Returns constant theme
ThemeData generateTheme(bool isDark, MaterialColor color) {
  if (isDark)
    return ThemeData.dark().copyWith(
        primaryColor: foreground,
        accentColor: color,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: color,
        ),
        backgroundColor: background);
  else
    return ThemeData.light().copyWith(
        accentColor: color,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: color,
        ),
        primaryColor: background,
        backgroundColor: foreground);
}

//
final ThemeData cyberpunkTheme = ThemeData.light().copyWith(
  primaryColor: Color.fromARGB(255, 0, 22, 238),
  accentColor: Color.fromARGB(255, 254, 0, 254),
  //Color.fromARGB(255, 119, 0, 106),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color.fromARGB(255, 254, 0, 254),
    foregroundColor: Colors.limeAccent, //Color.fromARGB(255, 0, 179, 254),
  ),
  backgroundColor: Colors.limeAccent,
  canvasColor: Colors.limeAccent,
  cardColor: Color.fromARGB(255, 255, 255, 0),
  //Color.fromARGB(255, 253,241,77),
  dialogBackgroundColor: Color.fromARGB(255, 255, 255, 0),
  //Color.fromARGB(255, 253,241,77),
  primaryColorLight: Color.fromARGB(255, 216, 188, 102),
  primaryColorDark: Color.fromARGB(255, 151, 141, 1),
  errorColor: Color.fromARGB(255, 227, 38, 54),
);

// Automatically generated boring themes
final ThemeData appThemeLightGreen = generateTheme(false, Colors.green);
final ThemeData appThemeLightYellow = generateTheme(false, Colors.yellow);
final ThemeData appThemeLightRed = generateTheme(false, Colors.red);
final ThemeData appThemeLightBlue = generateTheme(false, Colors.blue);
final ThemeData appThemeLightPurple = generateTheme(false, Colors.deepPurple);

final ThemeData appThemeDarkGreen = generateTheme(true, Colors.green);
final ThemeData appThemeDarkYellow = generateTheme(true, Colors.yellow);
final ThemeData appThemeDarkRed = generateTheme(true, Colors.red);
final ThemeData appThemeDarkBlue = generateTheme(true, Colors.blue);
final ThemeData appThemeDarkPurple = generateTheme(true, Colors.deepPurple);
