import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

class NotesDatabaseService {
  String path;

  NotesDatabaseService._();

  static final NotesDatabaseService db = NotesDatabaseService._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await init();
    return _database;
  }

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

  Future<List<NotificationModel>> getNotificationForNote(int id) async {
    final db = await database;
    List<NotificationModel> notesList = [];
    List<Map> maps =
    await db.query('Notifications', columns: ['_id', 'note', 'date1'], where: "note = ?", whereArgs: [id]);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotificationModel.fromMap(map));
      });
    }
    return notesList;
  }

  updateNoteInDB(NotesModel updatedNote) async {
    final db = await database;
    await db.update('Notes', updatedNote.toMap(),
        where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  updateNotificationInDB(NotificationModel updatedNotification)async{
    final db = await database;
    await db.update('Notifications', updatedNotification.toMap(),
        where: '_id = ?', whereArgs: [updatedNotification.id]);
  }

  Future<bool> deleteNoteInDB(NotesModel noteToDelete) async {
    final db = await database;
    final res = await db.delete('Notes', where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
    return true;
  }

  Future<bool> deleteNotificationInDB(NotificationModel noteToDelete) async {
    final db = await database;
    final res = await db.delete('Notifications', where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Notification deleted');
    return true;
  }

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

  Future<NotificationModel> addNotificationInDB(NotificationModel newNote) async {
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

class NotesModel {
  int id;
  String content;
  DateTime date;

  NotesModel({this.id, this.content, this.date});

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'content': this.content,
      'date': this.date.toIso8601String(),
    };
  }
}

class NotificationModel{
  int id;
  int note;
  String date1;

  NotificationModel({this.id, this.note, this.date1});

  NotificationModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.note = map['note'];
    this.date1 = map['date1'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'note': this.note,
      'date1': this.date1,
    };
  }

  makeData(DateTime dateTime, bool delete){
    date1 = dateTime.toIso8601String();
  }

}
