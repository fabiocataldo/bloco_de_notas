import 'package:bloconotas/model/Note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  //Singleton
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  static final String tableName = "note";

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initializeDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $tableName ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "title VARCHAR, "
        "description TEXT, "
        "date DATETIME)";
    await db.execute(sql);
  }

  initializeDB() async {
    final pathBD = await getDatabasesPath();
    final localDB = join(pathBD, "db.db");

    var db = await openDatabase(localDB, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> saveNote(Note note) async {
    var dataBase = await db;

    int id = await dataBase.insert(tableName, note.toMap());
    return id;
  }

  getNote() async {
    var dataBase = await db;
    String sql = "SELECT * FROM $tableName ORDER BY date DESC";
    List notes = await dataBase.rawQuery(sql);
    return notes;
  }

  Future<int> updateNote(Note note) async {
    var bd = await db;
    return await bd
        .update(tableName, note.toMap(), where: "id = ?", whereArgs: [note.id]);
  }

  Future<int> removeNote(int id) async {
    var bd = await db;
    return await bd.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}
