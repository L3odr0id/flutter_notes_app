import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:trpp/data/data.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:trpp/screens/note.dart';

/// Slider for scheduling a notification
class AddNotificationDialog {
  BuildContext _context;
  bool _isSwitched = false;
  Function getResult;

  DateTime _chosenTime;
  bool _chosenDelete;

  AddNoteScreenState parent;

  AddNotificationDialog(BuildContext context, Function getResult, NotesModel nm,
      AddNoteScreenState parent) {
    _context = context;
    this.getResult = getResult;
    this.parent = parent;

    _chosenTime = DateTime.now();
    _chosenDelete = _isSwitched;

    initTimeZone();
  }

  /// Initializes user timezone
  void initTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
  }

  /// Opens slider
  void showDialog() {
    slideDialog.showSlideDialog(
      context: _context,
      child: _widget(),
    );
  }

  Widget _widget() {
    // Main structure of the slider
    return SafeArea(
      child: Column(
        children: [
          Text('Notification options',
              style: TextStyle(
                  fontSize: 24, color: Theme.of(_context).primaryColor)),
          _picker2(),
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: _removeBtn(),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: _okBtn(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _picker2() {
    // DataTime picker widget
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
          initialDateTime: getInitialDateTime(),
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

  /// Returns time that was scheduled if user already created a notification
  DateTime getInitialDateTime() {
    if (parent.notificationModel != null)
      return DateTime.parse(parent.notificationModel.date1);
    else
      return DateTime.now();
  }

  Widget _okBtn() {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: OutlineButton(
        onPressed: () {
          Navigator.of(_context).pop();
          saveNotification();
          getResult(_chosenTime, _chosenDelete);
        },
        highlightedBorderColor: Theme.of(_context).accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Text(
          'OK',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Theme.of(_context).accentColor),
        ),
      ),
    );
  }

  Widget _removeBtn() {
    return Padding(
      padding: EdgeInsets.only(left: 24),
      child: OutlineButton(
        onPressed: () {
          Navigator.of(_context).pop();
          cancelScheduledNotification();
        },
        highlightedBorderColor: Theme.of(_context).accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Text(
          'Cancel',
          style: TextStyle(fontSize: 14, color: Theme.of(_context).errorColor),
        ),
      ),
    );
  }

  /// Schedules notification
  scheduleNotification() async {
    if (parent.nm != null) {
      FlutterLocalNotificationsPlugin plugin =
          FlutterLocalNotificationsPlugin();
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
            parent.notificationModel.note,
            parent.nm.getTitleFromModel(16),
            parent.nm.getShortDesc(24),
            getTime(),
            const NotificationDetails(
                android: AndroidNotificationDetails('your channel id',
                    'Notifications', 'Channel for your alarms')),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    }
  }

  /// Cancels notifications
  void cancelScheduledNotification() {
    print("Cancel");
    if (parent.notificationModel != null) {
      if (parent.notificationModel.id != null) {
        FlutterLocalNotificationsPlugin plugin =
            FlutterLocalNotificationsPlugin();
        plugin.cancel(parent.notificationModel.note);
        NotesDatabaseService.db
            .deleteNotificationInDB(parent.notificationModel);
        parent.notificationModel = null;
      }
    }
  }

  /// Gets time from DateTimePicker
  tz.TZDateTime getTime() {
    tz.TZDateTime a = tz.TZDateTime.from(_chosenTime, tz.local);
    return a;
  }

  /// Saves notification in db
  saveNotification() async {
    cancelScheduledNotification();
    parent.notificationModel = new NotificationModel();
    parent.notificationModel.makeData(_chosenTime);
    if (parent.nm != null) parent.notificationModel.note = parent.nm.id;
    parent.notificationModel = await NotesDatabaseService.db
        .addNotificationInDB(parent.notificationModel);
    if (parent.notificationModel.id != null) scheduleNotification();
  }

  /// DummyFunction
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async{return;}

  /// DummyFunction
  Future selectNotification(String payload) async{
    if (payload != null) {
      debugPrint('notification payload: $payload');
      return;
    }
  }
}
