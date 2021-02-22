import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class AddNoteScreen extends StatelessWidget {

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
                  // TODO save note
                  Navigator.pop(context);
              },
            ),
            Flexible(child: CustomTextField(maxLines: 50, hintText: 'Note')),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final int maxLines;
  final String hintText;
  CustomTextField({this.maxLines,this.hintText});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
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