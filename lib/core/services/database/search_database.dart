import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "my_database.db";
  static const _databaseVersion = 1;
  static const table = 'my_table';
  static const columnText = 'text';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database object reference
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnText TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(String text) async {
    Database db = await instance.database;
    return await db.insert(table, {columnText: text});
  }

  Future<List<String>> queryAllRows() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(table);
    return List.generate(result.length, (i) => result[i][columnText]);
  }

  Future<int> delete(String text) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnText = ?', whereArgs: [text]);
  }
}