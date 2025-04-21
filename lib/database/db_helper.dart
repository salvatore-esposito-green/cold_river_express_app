import 'dart:async';
import 'package:cold_river_express_app/database/query_labels.dart';
import 'package:cold_river_express_app/utils/get_path.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final String version = "7";

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDB('inventor_version_$version.db');
    } else {
      int currentVersion = await _database!.getVersion();

      if (currentVersion < int.parse(version)) {
        if (kDebugMode) {
          print('Upgrading database from version $currentVersion to $version');
        }

        /*
        ** This functionality was introduced in version 1.0.4.
        ** It supports the implementation of soft delete, allowing records to be
        ** marked as inactive instead of being permanently removed.
        */
        if (currentVersion < 7) {
          await _database!.execute(
            'ALTER TABLE inventory ADD COLUMN is_deleted INTEGER DEFAULT 0',
          );
        }

        _database = await _initDB('inventor_version_$version.db');
      }
    }
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    final String path = join(documentsDirectory.path, fileName);

    final File dbFile = File(
      join(documentsDirectory.path, 'inventor_version_$version.db'),
    );

    final String? extDir = await getPath();

    final File backupFile = File(
      join(extDir!, 'backup_inventor_version_$version.db'),
    );

    await dbFile.copy(backupFile.path);

    return await openDatabase(
      path,
      version: int.parse(version),
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute(QueryLabels.createInventoryTable);

    await db.execute(QueryLabels.createBoxSizesTable);

    await db.insert('box_sizes', {'length': 60, 'width': 40, 'height': 40});
    await db.insert('box_sizes', {'length': 60, 'width': 40, 'height': 35});
    await db.insert('box_sizes', {'length': 60, 'width': 30, 'height': 30});
    await db.insert('box_sizes', {'length': 80, 'width': 40, 'height': 40});
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

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => Inventory.fromMap(maps[i]));
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

    return await db.update(
      'inventory',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> recoverInventory(int id) async {
    final db = await database;

    return await db.update(
      'inventory',
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Inventory>> getDeletedInventories() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'is_deleted = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) => Inventory.fromMap(maps[i]));
  }

  Future<List<Inventory>> freeSearchInventory(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: 'contents LIKE ? AND is_deleted = ?',
      whereArgs: ['%$query%', 0],
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

    String whereClause = 'is_deleted = ?';
    List<dynamic> whereArgs = [0];

    if (environment != null) {
      whereClause += ' AND environment = ?';
      whereArgs.add(environment);
    }
    if (position != null) {
      whereClause += ' AND position = ?';
      whereArgs.add(position);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
      where: whereClause,
      whereArgs: whereArgs,
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

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<bool> replaceDatabase(String backupFilePath) async {
    var response = false;

    await close();

    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    final String currentDbPath = join(
      documentsDirectory.path,
      'inventor_version_$version.db',
    );

    final File backupFile = File(backupFilePath);

    final File currentDbFile = File(currentDbPath);

    if (await backupFile.exists()) {
      await backupFile.copy(currentDbPath);

      if (kDebugMode) {
        print('Database replaced successfully.');
      }
      response = true;
    } else {
      response = false;
      throw Exception('Backup file not found at $backupFilePath');
    }

    await database;

    return response;
  }

  Future<void> updateImagePath(String oldPath, String newPath) async {
    final db = await database;

    await db.update(
      'inventory',
      {'image_path': newPath},
      where: 'image_path = ?',
      whereArgs: [oldPath],
    );
  }
}
