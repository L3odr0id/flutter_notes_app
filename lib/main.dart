import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

import 'data/theme.dart';
import 'screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setThemeAndRun();
}

setThemeAndRun() async {
  TupleTheme savedTheme = (await getCurrentTheme());
  print("setTheme home " + savedTheme.name);

  runApp(MyApp(
    theme: savedTheme.theme,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeData theme;

  MyApp({Key key, this.theme}) : super(key: key);

  @override
  _AppState createState() => _AppState(theme);
}

class _AppState extends State<MyApp> {
  _AppState(ThemeData theme) {
    chosenTheme = theme;
  }

  ThemeData chosenTheme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: chosenTheme.brightness,
        data: (brightness) => chosenTheme,
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Notes app',
            theme: theme,
            home: HomeScreen(),
          );
        });
  }
}
