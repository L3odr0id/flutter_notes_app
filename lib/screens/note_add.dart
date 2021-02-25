import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:trpp/data/data.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'voice.dart';

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

  stt.SpeechToText _speech;
  bool _isListening = false;
  bool keyboardIsUp = false;

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        child: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
        visible: !keyboardIsUp,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isNew) contentController.text = nm.content;
    _speech = stt.SpeechToText();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        keyboardIsUp = visible;
        setState(() {});
      },
    );
  }

  String getText() {
    String res;
    if (nm != null)
      res = nm.content;
    else
      res = "";
    return res;
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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            if (mode == NOTESCREEN_MODE_VIEW)
              nm.content += val.recognizedWords;
            else
              contentController.text += val.recognizedWords;

            //if (val.hasConfidenceRating && val.confidence > 0) {
            //_confidence = val.confidence;
            //}
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
        autofocus: true,
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
