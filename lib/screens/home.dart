import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trpp/data/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/widgets/custom_alert_dialog.dart';

import 'note_add.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title, changeTheme}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  ThemeData theme = appThemeLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            HomeAppBar(),
            CustomListView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.plus),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddNoteScreen())),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 5, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Home',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.cog, size: 22),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class CustomDismissible extends StatelessWidget {
  const CustomDismissible({Key key, this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey(index),
      direction: DismissDirection.endToStart,
      child: Card(child: CustomListTile(index)),
      background: Padding(
        padding: EdgeInsets.only(right: 30),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(FontAwesomeIcons.trashAlt,
              color: Color(0xFFFA8182), size: 28),
        ),
      ),
      //TODO onDismissed:
      confirmDismiss: (direction) => showDialog(
          context: context, builder: (context) => CustomAlertDialog()),
    );
  }
}

class CustomListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context,index) => CustomDismissible(index: index),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  CustomListTile(this.index);
  final int index;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Text(
        "title",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          "Note text",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        ),
      ),
      trailing: Text(
        "some info",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xff959EA7),
        ),
      ),
      //TODO onTap:
      contentPadding: EdgeInsets.all(17),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}