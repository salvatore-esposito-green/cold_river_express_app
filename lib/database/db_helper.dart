import 'dart:async';
import 'package:cold_river_express_app/database/query_labels.dart';
import 'package:flutter/foundation.dart';
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
    if (_database == null) {
      _database = await _initDB('inventoryColdRiver.db');
    } else {
      int currentVersion = await _database!.getVersion();
      int requiredVersion = 4;

      if (currentVersion < requiredVersion) {
        if (kDebugMode) {
          print(
            'Upgrading database from version $currentVersion to $requiredVersion',
          );
        }

        _database = await _initDB('inventoryColdRiver.db');
      }
    }
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    final String path = join(documentsDirectory.path, fileName);

    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(QueryLabels.createInventoryTable);
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

  Future<int> updateInventory(Inventory inventory) async {
    final db = await database;

    return await db.update(
      'inventory',
      inventory.toMap(),
      where: 'id = ?',
      whereArgs: [inventory.id],
    );
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

  Future<int> updateInventoriesPosition(
    List<String> ids,
    String position,
  ) async {
    final db = await database;

    return await db.transaction<int>((txn) async {
      return await txn.update(
        'inventory',
        {'position': position},
        where: 'id IN (${ids.map((_) => '?').join(',')})',
        whereArgs: ids,
      );
    });
  }

  Future<List<Inventory>> filterInventory(
    String? environment,
    String? position,
  ) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (environment != null) {
      whereClause += 'environment = ?';
      whereArgs.add(environment);
    }
    if (position != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'position = ?';
      whereArgs.add(position);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) => Inventory.fromMap(maps[i]));
  }

  Future<List<String>> getLabelForEnvironment() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      QueryLabels.selectUniqueEnvironments,
    );

    return result.map((row) => row.values.first.toString()).toList();
  }

  Future<List<String>> getLabelForPosition() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      QueryLabels.selectUniquePositions,
    );

    return result.map((row) => row.values.first.toString()).toList();
  }
}
