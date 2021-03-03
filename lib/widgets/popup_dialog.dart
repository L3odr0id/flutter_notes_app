import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:trpp/data/data.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:trpp/screens/note.dart';

class AddNotificationDialog {
  BuildContext _context;
  bool _isSwitched = false;
  Function getResult;

  DateTime _chosenTime;
  bool _chosenDelete;

//  NotificationModel notificationModel;
  //bool isNotificationNew;

  NotesModel notesModel;

  AddNoteScreenState parent;

  AddNotificationDialog(BuildContext context, Function getResult, NotesModel nm,
      AddNoteScreenState parent) {
    _context = context;
    this.getResult = getResult;
    this.parent = parent;

    _chosenTime = DateTime.now();
    _chosenDelete = _isSwitched;

    initTimeZone();
    notesModel = nm;
  }

  void initTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
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
          _removeBtn(),
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
          saveNotification();
          getResult(_chosenTime, _chosenDelete);
        },
        child: Text("ok"));
  }

  Widget _removeBtn() {
    return FlatButton(
        onPressed: () {
          Navigator.of(_context).pop();
          cancelScheduledNotification();
        },
        child: Text("Cancel notification"));
  }

  scheduleNotification() async {
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await plugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    if (getTime().isAfter(DateTime.now())) {
      print("scheduled to:" + parent.notificationModel.date1);
      await plugin.zonedSchedule(
          parent.notificationModel.id,
          notesModel.getTitleFromModel(8),
          notesModel.getShortDesc(16),
          getTime(),
          const NotificationDetails(
              android: AndroidNotificationDetails('your channel id',
                  'Notifications', 'Channel for your alarms')),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  void cancelScheduledNotification() {
    print("Cancel");
    if (parent.notificationModel.id != null) {
      FlutterLocalNotificationsPlugin plugin =
          FlutterLocalNotificationsPlugin();
      plugin.cancel(parent.notificationModel.id);
      NotesDatabaseService.db.deleteNotificationInDB(parent.notificationModel);
      parent.isNotificationNew = true;
      parent.isNotificationNew = true;
    }
  }

  tz.TZDateTime getTime() {
    tz.TZDateTime a = tz.TZDateTime.from(_chosenTime, tz.local);
    return a;
  }

  saveNotification() async {
    cancelScheduledNotification();
    parent.notificationModel.makeData(_chosenTime);
    if (parent.isNotificationNew)
      parent.notificationModel = await NotesDatabaseService.db
          .addNotificationInDB(parent.notificationModel);

    if (parent.isNotificationNew && parent.notificationModel.id != null)
      scheduleNotification();
  }

  // ignore: missing_return
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {}

  // ignore: missing_return
  Future selectNotification(String payload) {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }
}
