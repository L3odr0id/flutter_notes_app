import 'dart:io';
import 'dart:math';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trpp/data/data.dart';
import 'package:trpp/data/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/widgets/custom_alert_dialog.dart';
import 'package:trpp/widgets/toolbar.dart';

import 'note.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  TupleTheme theme;
  List<NotesModel> notesList = [];
  List<NotificationModel> notificationList = [];

  bool _inDeletion = false;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
    setNotificationFormDB();
    setLocalTheme();
  }

  setLocalTheme()async{
    theme = (await getCurrentTheme());
  }

  setNotesFromDB() async {
    if (!_inDeletion) {
      var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
      notesList = fetchedNotes;
    } else
      print("Skip notes list update due to deletion");
    setState(() {});
  }

  setNotificationFormDB() async {
    var fetchedNotes = await NotesDatabaseService.db.getNotificationsFromDB();
    notificationList = fetchedNotes;
    deleteBadNotifications();
    setState(() {});
  }

  deleteBadNotifications() async {
    List<NotificationModel> badGuys = List<NotificationModel>();
    for (int i = 0; i < notificationList.length; ++i) {
      if (DateTime.parse(notificationList[i].date1).isBefore(DateTime.now())) {
        NotesDatabaseService.db.deleteNotificationInDB(notificationList[i]);
        badGuys.add(notificationList[i]);
      }
    }

    for (int i = 0; i < badGuys.length; ++i)
      notificationList.remove(badGuys[i]);

    if (badGuys.isNotEmpty) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            //HomeAppBar(),
            CustomToolbar(
              needBackBtn: false,
              title: "Home",
              icon: FontAwesomeIcons.cog,
              onPressed: openSettings,
            ),
            CustomListView(
              notesList: notesList,
              openNote: openNote,
              onDismissed: dismissNote,
              notificationList: notificationList,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 8, bottom: 46),
        child: FloatingActionButton(
            child: Icon(FontAwesomeIcons.plus),
            onPressed: () => openNote(NOTESCREEN_MODE_EDIT, null, true, null)),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  void openSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsScreen(title: theme,)));
  }

  void openNote(bool mode, NotesModel nm, bool isNew,
      NotificationModel notificationModel) async {
    final res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddNoteScreen(
                oldNm: nm,
                isNew: isNew,
                mode: mode,
                notificationModel: notificationModel)));
    if (res != null && res) {
      setNotesFromDB();
      setNotificationFormDB();
    }
  }

  dismissNote(NotesModel nm) async {
    _inDeletion = true;
    _inDeletion = !(await NotesDatabaseService.db.deleteNoteInDB(nm));
    notesList.remove(nm);
    setState(() {});
  }
}

// TODO delete deprecated class
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
  CustomDismissible(
      {Key key,
      this.index,
      this.nm,
      this.openNote,
      this.onDismissed,
      this.notificationModel})
      : super(key: key);
  final int index;
  final NotesModel nm;
  final NotificationModel notificationModel;
  final Function openNote;
  final Function onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(index),
      direction: DismissDirection.endToStart,
      child: Card(child: NoteListItem(index, nm, openNote, notificationModel)),
      background: Padding(
        padding: EdgeInsets.only(right: 30),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(FontAwesomeIcons.trashAlt,
              color: Colors.red.shade500, size: 28),
        ),
      ),
      onDismissed: (direction) {
        onDismissed(nm);
      },
      confirmDismiss: (direction) => showDialog(
          context: context, builder: (context) => CustomAlertDialog()),
    );
  }
}

class CustomListView extends StatelessWidget {
  final List<NotesModel> notesList;
  final List<NotificationModel> notificationList;
  final Function openNote;
  final Function onDismissed;

  CustomListView(
      {Key key,
      this.notesList,
      this.openNote,
      this.onDismissed,
      this.notificationList})
      : super(key: key);

  NotificationModel getModel(int index) {
    for (int i = 0; i < notificationList.length; ++i)
      if (notificationList[i].note == notesList[index].id)
        return notificationList[i];

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        itemCount: notesList.length,
        itemBuilder: (context, index) => CustomDismissible(
          index: index,
          nm: notesList[index],
          openNote: openNote,
          onDismissed: onDismissed,
          notificationModel: getModel(index),
        ),
      ),
    );
  }
}

class NoteListItem extends StatelessWidget {
  NoteListItem(this.index, this.nm, this.openNote, this.notificationModel);

  final int index;
  final NotesModel nm;
  final NotificationModel notificationModel;
  final Function openNote;

  String getText() {
    if (notificationModel != null)
      return notificationModel.getString();
    else
      return "";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        nm.getTitleFromModel(16),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Theme.of(context).primaryColor,),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          nm.getShortDesc(24),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Theme.of(context).primaryColor,),
        ),
      ),
      trailing: Text(
        getText(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).accentColor,
        ),
      ),
      onTap: () => openNote(NOTESCREEN_MODE_VIEW, nm, false, notificationModel),
      contentPadding: EdgeInsets.all(17),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Theme.of(context).cardColor,
    );
  }
}
