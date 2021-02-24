import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trpp/data/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key, this.title, changeTheme}) : super(key: key);

  final String title;

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TupleTheme dropdownValue;

  @override
  void initState() {
    super.initState();
    getDropDownValue();
  }

  getDropDownValue() async {
    dropdownValue = await getCurrentTheme();
    setState(() {});
  }

  setTheme(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            toolBar(),
            topCard(),
          ],
        ),
        buildCardWidget(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('About app',
                style: TextStyle(
                    fontSize: 24, color: Theme.of(context).primaryColor)),
            Container(
              height: 40,
            ),
            gitButton(),
            flutterLogo(),
          ],
        ))
      ],
    ));
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

  Widget toolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back, size: 27),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
  }

  Widget dropDownItem() {
    return DropdownButton<TupleTheme>(
      value: dropdownValue,
      icon: Icon(FontAwesomeIcons.caretDown),
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
        setTheme(newValue.name);
      },
      items: ThemeNames.map<DropdownMenuItem<TupleTheme>>((TupleTheme value) {
        return DropdownMenuItem<TupleTheme>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }

  Widget topCard() {
    return buildCardWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('App Theme', style: TextStyle(fontSize: 24)),
          Container(
            height: 20,
          ),
          dropDownItem(),
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
      Container(
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
      )
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
