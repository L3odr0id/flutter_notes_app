import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

/// Stores and loads data form .SQLITE db
class NotesDatabaseService {
  String path;
  NotesDatabaseService._();
  static final NotesDatabaseService db = NotesDatabaseService._();
  Database _database;

  /// Returns database
  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await init();
    return _database;
  }

  /// Initializes database
  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'notes.db');
    print("Entered path $path");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Notes (_id INTEGER PRIMARY KEY, content TEXT, date TEXT);');
      await db.execute(
          'CREATE TABLE Notifications (_id INTEGER PRIMARY KEY, note INTEGER, date1 TEXT);');
      print('New table created at $path');
    });
  }

  /// Gets notes from DB
  Future<List<NotesModel>> getNotesFromDB() async {
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map> maps =
        await db.query('Notes', columns: ['_id', 'content', 'date']);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotesModel.fromMap(map));
      });
    }
    return notesList;
  }

  /// Gets notifications from DB
  Future<List<NotificationModel>> getNotificationsFromDB() async {
    final db = await database;
    List<NotificationModel> notesList = [];
    List<Map> maps =
        await db.query('Notifications', columns: ['_id', 'note', 'date1']);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotificationModel.fromMap(map));
      });
    }
    return notesList;
  }

  /// Gets notifications from specific note
  Future<List<NotificationModel>> getNotificationForNote(int id) async {
    final db = await database;
    List<NotificationModel> notesList = [];
    List<Map> maps = await db.query('Notifications',
        columns: ['_id', 'note', 'date1'], where: "note = ?", whereArgs: [id]);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotificationModel.fromMap(map));
      });
    }
    return notesList;
  }

  /// Updates note in database
  updateNoteInDB(NotesModel updatedNote) async {
    final db = await database;
    await db.update('Notes', updatedNote.toMap(),
        where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  /// Updates notification in database
  updateNotificationInDB(NotificationModel updatedNotification) async {
    final db = await database;
    await db.update('Notifications', updatedNotification.toMap(),
        where: '_id = ?', whereArgs: [updatedNotification.id]);
  }

  /// Deletes note from database
  Future<bool> deleteNoteInDB(NotesModel noteToDelete) async {
    final db = await database;
    final res = await db
        .delete('Notes', where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
    return true;
  }

  /// Deletes notification from database
  Future<bool> deleteNotificationInDB(NotificationModel noteToDelete) async {
    final db = await database;
    final res = await db.delete('Notifications',
        where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Notification deleted');
    return true;
  }

  /// Adds note in database
  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    final db = await database;
    int id = await db.transaction((transaction) {
      return transaction.rawInsert(
          'INSERT into Notes(content, date) VALUES ( "${newNote.content}", "${newNote.date.toIso8601String()}");');
    });
    newNote.id = id;
    print('Note added: ${newNote.content}');
    return newNote;
  }

  /// Adds notification in database
  Future<NotificationModel> addNotificationInDB(
      NotificationModel newNote) async {
    final db = await database;
    int id = await db.transaction((transaction) {
      return transaction.rawInsert(
          'INSERT into Notifications(note, date1) VALUES ( "${newNote.note}", "${newNote.date1}");');
    });
    newNote.id = id;
    print('Notification added: ${newNote.date1}');
    return newNote;
  }
}

/// Model for database
class NotesModel {
  int id;
  String content;
  DateTime date;

  NotesModel({this.id, this.content, this.date});

  /// Makes NotesModel from database data
  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
  }

  /// Prepares data to store it in database
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'content': this.content,
      'date': this.date.toIso8601String(),
    };
  }

  /// Gets string to set it as note title
  String getTitleFromModel(int maxSymbols) {
    List<String> a = content.split("\n");
    return a.first.substring(0, min(a.first.length, maxSymbols));
  }

  /// Gets string to set it as note description
  String getShortDesc(int maxSymbols) {
    List<String> a = content.split("\n");
    if (a.length > 1) {
      return a[1].substring(0, min(a[1].length, maxSymbols));
    } else
      return "";
  }
}

/// Model for notification
class NotificationModel {
  int id;
  int note;
  String date1;

  NotificationModel({this.id, this.note, this.date1});

  /// Makes NotificationModel from database data
  NotificationModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    print(map['note']);
    this.note = map['note'];
    this.date1 = map['date1'];
  }

  /// Prepares data to store it in database
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'note': this.note,
      'date1': this.date1,
    };
  }

  /// Sets date info
  makeData(DateTime dateTime) {
    date1 = dateTime.toIso8601String();
  }

  /// Returns all data converted in string
  String getString() {
    DateTime time = DateTime.parse(date1);
    String month = time.month.toString();
    if (month.length == 1) month = "0" + month;
    return "Notify ${time.day}.$month at ${time.hour}:${time.minute}";
  }
}
