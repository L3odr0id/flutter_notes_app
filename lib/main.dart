import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

import 'data/theme.dart';
import 'screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: ThemeNames[0].theme.brightness,
        data: (brightness) => ThemeNames[0].theme,
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Notes app',
            theme: theme,
            home: HomeScreen(),
          );
        }
    );
  }
}

