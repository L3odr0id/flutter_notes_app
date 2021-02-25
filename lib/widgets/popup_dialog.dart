import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class AddNotificationDialog {
  BuildContext _context;
  bool _isSwitched = false;
  Function getResult;

  DateTime _chosenTime;
  bool _chosenDelete;

  AddNotificationDialog(BuildContext context, Function getResult) {
    _context = context;
    this.getResult = getResult;

    _chosenTime = DateTime.now();
    _chosenDelete = _isSwitched;
  }

  void showDialog() {
    slideDialog.showSlideDialog(
      context: _context,
      child: _widget(),
    );
  }

  Widget _widget() {
    return SafeArea(
      child: Column(
        children: [
          Text("Add notification"),
          _picker2(),
          //_switchToDelete(),
          _okBtn(),
        ],
      ),
    );
  }

  Widget _picker2() {
    return Container(
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              fontSize: 18,
              color: Theme.of(_context).primaryColor,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          initialDateTime: DateTime.now(),
          onDateTimeChanged: (dateTime) {
            _chosenTime = dateTime;
          },
          use24hFormat: true,
        ),
      ),
      width: 400,
      height: 300,
    );
  }

  Widget _switchToDelete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Delete note after notification"),
        Switch(value: _isSwitched, onChanged: (value) => _isSwitched = value)
      ],
    );
  }

  Widget _okBtn() {
    return FlatButton(
        onPressed: () {
          Navigator.of(_context).pop();
          getResult(_chosenTime, _chosenDelete);
        },
        child: Text("ok"));
  }
}
