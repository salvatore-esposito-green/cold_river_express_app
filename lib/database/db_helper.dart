import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    final String path = join(documentsDirectory.path, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory (
        id TEXT PRIMARY KEY,
        boxNumber TEXT,
        contents TEXT,
        imagePath TEXT,
        size TEXT,
        position TEXT,
        lastUpdated TEXT
      )
    ''');
  }

  Future<int> insertInventory(Inventory inventory) async {
    final db = await database;
    return await db.insert(
      'inventory',
      inventory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Inventory>> getInventories() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('inventory');

    return List.generate(maps.length, (i) {
      return Inventory.fromMap(maps[i]);
    });
  }

  Future<Inventory?> getInventory(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Inventory.fromMap(maps.first);
    }

    return null;
  }

  Future<int> deleteInventory(String id) async {
    final db = await database;

    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Inventory>> freeSearchInventory(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'contents LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) => Inventory.fromMap(maps[i]));
  }
}
