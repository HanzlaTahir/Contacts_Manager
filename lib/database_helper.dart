import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'contacts.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        image TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE contacts ADD COLUMN image TEXT');
    }
  }

  Future<void> insertContact(Map<String, dynamic> contact) async {
    Database db = await database;
    await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    Database db = await database;
    return await db.query('contacts');
  }

  Future<void> deleteContact(int id) async {
    Database db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateContactPhone(int id, String newPhone) async {
    Database db = await database;
    await db.update(
      'contacts',
      {'phone': newPhone},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateContactImage(int id, String newImage) async {
    Database db = await database;
    await db.update(
      'contacts',
      {'image': newImage},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
