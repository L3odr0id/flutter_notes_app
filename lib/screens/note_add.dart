import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/data/data.dart';

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen({Key key, this.isNew, this.nm}) : super(key: key);
  final bool isNew;
  final NotesModel nm;
  final TextEditingController contentController = TextEditingController();

  @override
  State<StatefulWidget> createState() => AddNoteScreenState(this);

  void onLoad() {
    if (!isNew) contentController.text = nm.content;
  }

  void handleSave() async {
    if (isNew) {
      if (contentController.text != "") {
        NotesModel nm =
            NotesModel(content: contentController.text, date: DateTime.now());
        NotesDatabaseService.db.addNoteInDB(nm);
      }
    } else {
      nm.content = contentController.text;
      nm.date = DateTime.now();
      NotesDatabaseService.db.updateNoteInDB(nm);
    }
  }
}

class AddNoteScreenState extends State<AddNoteScreen> {
  AddNoteScreenState(this.widget);

  final AddNoteScreen widget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CustomToolbar(
              title: 'Add Note',
              icon: FontAwesomeIcons.solidSave,
              onPressed: () {
                widget.handleSave();
                //Navigator.pop(context);
              },
              backToMenu: () {
                backToMenu();
              },
            ),
            Flexible(
              child: CustomTextField(
                  maxLines: 50,
                  hintText: 'Note',
                  controller: widget.contentController),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.onLoad();
  }

  void backToMenu() {
    if (widget.isNew)
      Navigator.pop(context);
    else {
      Navigator.pop(context);
      Navigator.pop(context);
    }
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
