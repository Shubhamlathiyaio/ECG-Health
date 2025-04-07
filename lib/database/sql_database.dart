import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static const _databaseName = 'imeiTracker.db';
  Database? _database;

  Future<Database?> get DatabaseHandler async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databaseName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE ECG(id INTEGER PRIMARY KEY AUTOINCREMENT, bpm TEXT NOT NULL,avh TEXT NOT NULL,avl TEXT NOT NULL,st TEXT NOT NULL,qrs TEXT NOT NULL,pq TEXT NOT NULL,ecgList TEXT NOT NULL,dateTime TEXT NOT NULL,V TEXT NOT NULL)''',
    );
  }

  Future<dynamic> ecgInformation(String bpm, String avh, String avl, String st,
      String qrs, String pq, String ecgLists,String dateTime, String V) async {
    Database? db = await instance.DatabaseHandler;
    var insert = await db!.insert("ECG", {
      'bpm': bpm,
      'avh': avh,
      'avl': avl,
      'st': st,
      'qrs': qrs,
      'pq': pq,
      'ecgList': ecgLists,
      'dateTime': dateTime,
      'V': V
    });
    return insert;
  }

  Future<dynamic> deviceInformationSelect() async {
    Database? db = await instance.DatabaseHandler;
    //var select = await db!.query('ECG', orderBy: 'id DESC');
    var select = await db!.query('ECG');
    // orderBy: 'id DESC' use to list Data up to Down
    // first data show last and new data show first in list
    return select;
  }

  Future<dynamic> timerDataDelete() async {
    Database? db = await instance.DatabaseHandler;
    var delete = await db!.delete("ECG");
    return delete;
  }
}
