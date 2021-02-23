import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/data/data.dart';

import 'note_view.dart';

const bool NOTESCREEN_MODE_VIEW = false;
const bool NOTESCREEN_MODE_EDIT = true;

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen({Key key, this.isNew, this.nm, this.mode}) : super(key: key);
  final bool isNew;
  final NotesModel nm;
  final TextEditingController contentController = TextEditingController();
  final bool mode;

  @override
  State<StatefulWidget> createState() => AddNoteScreenState(this, mode);

  void onLoad() {
    if (!isNew) contentController.text = nm.content;
  }
}

class AddNoteScreenState extends State<AddNoteScreen> {
  AddNoteScreenState(this.widget, this.mode);

  final AddNoteScreen widget;
  bool mode;

  @override
  Widget build(BuildContext context) {
    StatelessWidget screen;

    if (mode == NOTESCREEN_MODE_VIEW)
      screen = new ViewScreen(
          mSetState: mSetState, getText: getText, widget: widget);
    else
      screen = new EditScreen(
          handleSave: handleSave, backToMenu: backToMenu, widget: widget);

    return Scaffold(
      body: SafeArea(
        child: screen,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onLoad();
  }

  String getText() {
    String res;
    if (widget.nm != null)
      res = widget.nm.content;
    else
      res = "";
    return res;
  }

  void handleSave() async {
    if (widget.isNew) {
      if (widget.contentController.text != "") {
        NotesModel nm = NotesModel(
            content: widget.contentController.text, date: DateTime.now());
        NotesDatabaseService.db.addNoteInDB(nm);
      }
    } else {
      widget.nm.content = widget.contentController.text;
      widget.nm.date = DateTime.now();
      NotesDatabaseService.db.updateNoteInDB(widget.nm);
    }
    mode = NOTESCREEN_MODE_VIEW;
    setState(() {});
  }

  void mSetState() {
    mode = NOTESCREEN_MODE_EDIT;
    setState(() {});
  }

  void backToMenu() {
    Navigator.pop(context);
  }
}

class EditScreen extends StatelessWidget {
  EditScreen({this.handleSave, this.backToMenu, this.widget});

  final Function handleSave;
  final Function backToMenu;
  final AddNoteScreen widget;

  @override
  Widget build(BuildContext context) {
    return  Column(
          children: [
            CustomToolbar(
              title: 'Edit Note',
              icon: FontAwesomeIcons.solidSave,
              onPressed: () {
                handleSave();
              },
              backToMenu: () {
                backToMenu();
              },
            ),
            CustomTextField(
                maxLines: 50,
                hintText: 'Note',
                controller: widget.contentController),
          ],
    );
  }
}

class ViewScreen extends StatelessWidget {
  ViewScreen({this.mSetState, this.getText, this.widget});

  final Function mSetState;
  final Function getText;
  final AddNoteScreen widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => mSetState(),
      child: ReadingTextField(
        text: getText(),
        fontWeight: FontWeight.w400,
        fontSize: 22,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final int maxLines;
  final String hintText;
  final TextEditingController controller;

  CustomTextField({this.maxLines, this.hintText, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hintText),
        onChanged: (input) {
          if (input != null) {
            // TODO save data
          }
        },
      ),
    );
  }
}

class CustomToolbar extends StatelessWidget {
  CustomToolbar({this.title, this.icon, this.onPressed, this.backToMenu});

  final String title;
  final IconData icon;
  final Function onPressed;
  final Function backToMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, size: 27),
            onPressed: () => backToMenu(),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
          IconButton(icon: Icon(icon, size: 22), onPressed: onPressed),
        ],
      ),
    );
  }
}
