import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trpp/data/data.dart';

import 'note_add.dart';

class ReadNoteScreen extends StatelessWidget {
  ReadNoteScreen(this.nm);

  final NotesModel nm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            //TODO Custom App bar
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddNoteScreen(isNew: false, nm: nm))),
              child: ReadingTextField(
                text: nm.content,
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class ReadingTextField extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  ReadingTextField({this.text, this.fontSize, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        enabled: false,
        maxLines: null,
        controller: TextEditingController(text: text),
        decoration: InputDecoration(fillColor: Colors.transparent),
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
    );
  }
}
