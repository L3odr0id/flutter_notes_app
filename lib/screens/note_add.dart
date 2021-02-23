import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trpp/data/data.dart';


class AddNoteScreen extends StatelessWidget {
  AddNoteScreen({Key key, this.isNew}) : super(key: key);
  final bool isNew;
  final TextEditingController contentController = TextEditingController();

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
                  handleSave();
                  //Navigator.pop(context);
              },
            ),
            Flexible(child: CustomTextField(maxLines: 50, hintText: 'Note',
              controller: contentController)
            ),
          ],
        ),
      ),
    );
  }

  void handleSave() async {
    if (isNew){
      if(contentController.text!="") {
        NotesModel nm = NotesModel(
            content: contentController.text, date: DateTime.now());
        print(contentController.text);
        NotesDatabaseService.db.addNoteInDB(nm);
      }
    }else{
      
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
          if(input != null) {
            // TODO save data
          }
        },
      ),
    );
  }
}


class CustomToolbar extends StatelessWidget {
  CustomToolbar({this.title,this.isVisible,this.icon,this.onPressed});
  final String title;
  final bool isVisible;
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
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
          Visibility(
            visible: isVisible ?? true,
            child: IconButton(icon: Icon(icon, size: 22), onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}

