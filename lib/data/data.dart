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
          print('New table created at $path');
        });
  }

  Future<List<NotesModel>> getNotesFromDB() async {
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map> maps = await db.query('Notes',
        columns: ['_id', 'content', 'date']);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotesModel.fromMap(map));
      });
    }
    print("data.dart getNotesFromDB ${notesList.length}");
    return notesList;
  }

  updateNoteInDB(NotesModel updatedNote) async {
    final db = await database;
    await db.update('Notes', updatedNote.toMap(),
        where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  deleteNoteInDB(NotesModel noteToDelete) async {
    final db = await database;
    await db.delete('Notes', where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
  }

  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    final db = await database;
    print("Doing insert");
    print(newNote.content);
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Notes(content, date) VALUES ( "${newNote.content}", "${newNote.date.toIso8601String()}");');
    });
    newNote.id = id;
    print('Note added: ${newNote.content}');
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
      'date': this.date.toIso8601String()
    };
  }
}