import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:trpp/data/data.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:trpp/widgets/popup_dialog.dart';
import 'package:trpp/widgets/toolbar.dart';

const bool NOTESCREEN_MODE_VIEW = false;
const bool NOTESCREEN_MODE_EDIT = true;

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen(
      {Key key, this.isNew, this.oldNm, this.mode, this.notificationModel})
      : super(key: key);
  final bool isNew;
  final NotesModel oldNm;
  final bool mode;
  final NotificationModel notificationModel;

  @override
  State<StatefulWidget> createState() =>
      AddNoteScreenState(this, mode, oldNm, isNew, notificationModel);
}

class AddNoteScreenState extends State<AddNoteScreen> {
  AddNoteScreenState(
      this.widget, this.mode, this.nm, this.isNew, this.notificationModel);

  final AddNoteScreen widget;
  bool isNew;
  bool mode;
  NotesModel nm;

  SpeechToText _speech;
  bool _isListening = false;
  bool keyboardIsUp = false;

  final TextEditingController contentController = TextEditingController();

  AddNotificationDialog addNotificationDialog;
  NotificationModel notificationModel;

  @override
  Widget build(BuildContext context) {
    StatelessWidget screen;

    if (mode == NOTESCREEN_MODE_VIEW)
      screen = new ViewScreen(
        mSetState: mSetState,
        getText: getText,
        handleDelete: handleDelete,
        widget: this,
      );
    else
      screen = new EditScreen(handleSave: handleSave, widget: this);

    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [Expanded(child: screen)],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MicrophoneButton(
                  isListening: _isListening,
                  listen: _listen,
                  keyboardIsUp: keyboardIsUp,
                ),
                Visibility(
                  child: FloatingActionButton(
                    child: getIconForNotificationBtn(),
                    onPressed: () => addNotificationDialog.showDialog(),
                  ),
                  visible: !keyboardIsUp,
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        onWillPop: onWillPop);
  }

  Future<bool> onWillPop() async {
    Navigator.pop(context, true);
    return true;
  }

  @override
  void initState() {
    super.initState();
    if (!isNew) contentController.text = nm.content;
    _speech = SpeechToText();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (!visible && mode == NOTESCREEN_MODE_EDIT) {
          if (isNew)
            addNewNote();
          else
            updateNote();
        }
        keyboardIsUp = visible;
        setState(() {});
      },
    );

    addNotificationDialog =
        AddNotificationDialog(context, getResFromPicker, nm, this);
  }

  Icon getIconForNotificationBtn() {
    if (notificationModel == null)
      return Icon(FontAwesomeIcons.bell);
    else
      return Icon(FontAwesomeIcons.solidBell);
  }

  void getResFromPicker(DateTime dateTime, bool delete) {
    setState(() {});
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
    if (isNew) {
      if (contentController.text != "") {
        addNewNote();
      }
    } else {
      updateNote();
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

  void addNewNote() async {
    if (contentController.text != "") {
      NotesModel newNm =
          NotesModel(content: contentController.text, date: DateTime.now());
      nm = await NotesDatabaseService.db.addNoteInDB(newNm);
      isNew = false;
      if (notificationModel != null) notificationModel.note = nm.id;
    }
  }

  void updateNote() {
    nm.content = contentController.text;
    nm.date = DateTime.now();
    NotesDatabaseService.db.updateNoteInDB(nm);
  }

  void saveObBackBtn() {
    if (isNew) {
      if (contentController.text != "") {
        addNewNote();
      }
    } else {
      updateNote();
    }
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
            if (mode == NOTESCREEN_MODE_VIEW) {
              nm.content += val.recognizedWords;
              contentController.text = nm.content;
              NotesDatabaseService.db.updateNoteInDB(nm);
            } else {
              contentController.text += val.recognizedWords;

              if (isNew)
                addNewNote();
              else
                updateNote();
            }
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
          additionalBack: widget.saveObBackBtn,
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
  ViewScreen({this.mSetState, this.getText, this.handleDelete, this.widget});

  final Function mSetState;
  final Function getText;
  final Function handleDelete;
  final AddNoteScreenState widget;

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
          additionalBack: widget.saveObBackBtn,
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
        style: TextStyle(color: Theme.of(context).primaryColor),
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

class MicrophoneButton extends StatelessWidget {
  final bool isListening;
  final Function listen;
  final bool keyboardIsUp;

  MicrophoneButton({this.isListening, this.listen, this.keyboardIsUp});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: AvatarGlow(
        animate: isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: listen,
          child: Icon(isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      visible: !keyboardIsUp,
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
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Theme.of(context).primaryColor),
      ),
    );
  }
}
