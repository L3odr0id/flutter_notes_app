import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/data/data.dart';

import 'note_view.dart';

const bool NOTESCREEN_MODE_VIEW = false;
const bool NOTESCREEN_MODE_EDIT = true;

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen({Key key, this.isNew, this.oldNm, this.mode}) : super(key: key);
  final bool isNew;
  final NotesModel oldNm;
  final bool mode;

  @override
  State<StatefulWidget> createState() => AddNoteScreenState(this, mode, oldNm);
}

class AddNoteScreenState extends State<AddNoteScreen> {
  AddNoteScreenState(this.widget, this.mode, this.nm);

  final AddNoteScreen widget;
  bool mode;
  NotesModel nm;

  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    StatelessWidget screen;

    if (mode == NOTESCREEN_MODE_VIEW)
      screen = new ViewScreen(
          mSetState: mSetState, getText: getText, handleDelete: handleDelete);
    else
      screen = new EditScreen(handleSave: handleSave, widget: this);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [Expanded(child: screen)],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  String getText() {
    String res;
    if (nm != null)
      res = nm.content;
    else
      res = "";
    return res;
  }

  void onLoad() {
    if (!widget.isNew) contentController.text = nm.content;
  }

  void handleSave() async {
    if (widget.isNew) {
      if (contentController.text != "") {
        NotesModel newNm =
            NotesModel(content: contentController.text, date: DateTime.now());
        nm = await NotesDatabaseService.db.addNoteInDB(newNm);
      }
    } else {
      nm.content = contentController.text;
      nm.date = DateTime.now();
      NotesDatabaseService.db.updateNoteInDB(nm);
    }
    mode = NOTESCREEN_MODE_VIEW;
    setState(() {});
  }

  void handleDelete() async {
    if (nm.id != null) NotesDatabaseService.db.deleteNoteInDB(nm);
    Navigator.pop(context, true);
  }

  void mSetState() {
    mode = NOTESCREEN_MODE_EDIT;
    setState(() {});
  }
}

class EditScreen extends StatelessWidget {
  EditScreen({this.handleSave, this.widget});

  final Function handleSave;
  final AddNoteScreenState widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomToolbar(
          title: 'Edit Note',
          icon: FontAwesomeIcons.solidSave,
          onPressed: () {
            handleSave();
          },
        ),
        Expanded(
          child: CustomTextField(
              maxLines: 50,
              hintText: 'Note',
              controller: widget.contentController),
        ),
      ],
    );
  }
}

class ViewScreen extends StatelessWidget {
  ViewScreen({this.mSetState, this.getText, this.handleDelete});

  final Function mSetState;
  final Function getText;
  final Function handleDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomToolbar(
          title: 'View Note',
          icon: FontAwesomeIcons.trash,
          onPressed: () {
            handleDelete();
          },
        ),
        GestureDetector(
          onTap: () => mSetState(),
          child: ReadingTextField(
            text: getText(),
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
      ],
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
  CustomToolbar({this.title, this.icon, this.onPressed});

  final String title;
  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, size: 27),
            onPressed: () => Navigator.pop(context, true),
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
