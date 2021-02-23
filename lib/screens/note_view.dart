import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReadNoteScreen extends StatelessWidget {
  final int index;
  ReadNoteScreen(this.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                //TODO Custom App bar
                ReadingTextField(
                  text: "Text",
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
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
  ReadingTextField({this.text,this.fontSize,this.fontWeight});

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