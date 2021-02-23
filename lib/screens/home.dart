import 'dart:math';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trpp/data/data.dart';
import 'package:trpp/data/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/widgets/custom_alert_dialog.dart';

import 'note_add.dart';
import 'note_view.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  ThemeData theme = appThemeLight;
  List<NotesModel> notesList = [];

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
  }

  setNotesFromDB() async {
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    notesList = fetchedNotes;
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            HomeAppBar(),
            CustomListView(notesList: notesList),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.plus),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddNoteScreen(isNew: true))),
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
  const CustomDismissible({Key key, this.index, this.nm}) : super(key: key);
  final int index;
  final NotesModel nm;

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey(index),
      direction: DismissDirection.endToStart,
      child: Card(child: NoteListItem(index, nm)),
      background: Padding(
        padding: EdgeInsets.only(right: 30),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(FontAwesomeIcons.trashAlt,
              color: Colors.red.shade500, size: 28),
        ),
      ),
      //TODO onDismissed:
      confirmDismiss: (direction) => showDialog(
          context: context, builder: (context) => CustomAlertDialog()),
    );
  }
}

class CustomListView extends StatelessWidget {
  final List<NotesModel> notesList;

  CustomListView({Key key, this.notesList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Notes: ${notesList.length}");
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        itemCount: notesList.length,
        itemBuilder: (context,index) => CustomDismissible(index: index, nm: notesList[index]),
      ),
    );
  }
}

class NoteListItem extends StatelessWidget {
  NoteListItem(this.index, this.nm);
  final int index;
  final NotesModel nm;

  String getTitleFromModel(NotesModel nm){
    List<String> a = nm.content.split("\n");
    return a.first.substring(0, min(a.length, 8));
  }

  String getShortDesc(NotesModel nm){
    List<String> a = nm.content.split("\n");
    if (a.length > 1){
      return a[1].substring(0, min(a.length, 16));
    }else
      return "";
  }

  @override
  Widget build(BuildContext context) {
    print("Building $index");
    return ListTile(
      title: Text(
        getTitleFromModel(nm),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          getShortDesc(nm),
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
          color: Theme.of(context).accentColor,
        ),
      ),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => ReadNoteScreen(index))),
      contentPadding: EdgeInsets.all(17),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}