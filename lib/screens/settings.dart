import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trpp/data/theme.dart';
import 'package:trpp/screens/note.dart';
import 'package:trpp/widgets/toolbar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key, this.title}) : super(key: key);

  final TupleTheme title;

  @override
  SettingsScreenState createState() => SettingsScreenState(title);
}

class SettingsScreenState extends State<SettingsScreen> {
  TupleTheme dropdownValue;

  SettingsScreenState(TupleTheme theme) {
    for (int i = 0; i < ThemeNames.length; ++i)
      if (ThemeNames[i].name == theme.name) dropdownValue = ThemeNames[i];
  }

  @override
  void initState() {
    super.initState();
  }

  saveTheme(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          //physics: BouncingScrollPhysics(), ListView
          children: <Widget>[
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //toolBar(),
                CustomToolbar(
                  title: "Settings",
                ),
                topCard(),
              ],
            ),
            Align(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildCardWidget(
                    Column(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Align(
                          child: Text('About app',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).primaryColor)),
                          alignment: Alignment.topLeft,
                        ),
                        Container(
                          height: 40,
                        ),
                        gitButton(),
                        flutterLogo(),
                      ],
                    ),
                  ),
                ],
              ),
              alignment: Alignment.bottomCenter,
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget buildCardWidget(Widget child) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 8),
                color: Colors.black.withAlpha(20),
                blurRadius: 16)
          ]),
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  Widget dropDownItem() {
    return DropdownButton<TupleTheme>(
      value: dropdownValue,
      icon: Icon(
        FontAwesomeIcons.caretDown,
        color: Theme.of(context).accentColor,
      ),
      iconSize: 16,
      elevation: 16,
      style: TextStyle(color: Theme.of(context).primaryColor),
      underline: Container(
        height: 2,
        color: Theme.of(context).accentColor,
      ),
      onChanged: (TupleTheme newValue) {
        setState(() {
          dropdownValue = newValue;
          DynamicTheme.of(context).setThemeData(newValue.theme);
        });
        saveTheme(newValue.name);
      },
      items: ThemeNames.map<DropdownMenuItem<TupleTheme>>((TupleTheme value) {
        return DropdownMenuItem<TupleTheme>(
          value: value,
          child: Text(value.name,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).primaryColor)),
        );
      }).toList(),
    );
  }

  Widget topCard() {
    return buildCardWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('App Theme',
              style: TextStyle(
                  fontSize: 24, color: Theme.of(context).primaryColor)),
          Container(
            height: 20,
          ),
          Align(
            alignment: Alignment.center,
            child: dropDownItem(),
          ),
        ],
      ),
    );
  }

  Widget gitButton() {
    return Column(children: <Widget>[
      Center(
        child: Text('This app is open source!'.toUpperCase(),
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                letterSpacing: 1)),
      ),
      Padding(
        padding: EdgeInsets.only(top: 4),
        child: Container(
          alignment: Alignment.center,
          child: OutlineButton.icon(
            icon: Icon(FontAwesomeIcons.link),
            label: Text('GITHUB',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.grey)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: openGitHub,
          ),
        ),
      ),
    ]);
  }

  Widget flutterLogo() {
    return Padding(
      child: Column(
        children: <Widget>[
          Center(
            child: Text('Made With'.toUpperCase(),
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlutterLogo(
                    size: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Flutter',
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 30.0),
    );
  }

  void openGitHub() {
    launch('https://github.com/L3odr0id/flutter_notes_app');
  }
}
