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
      if (!_database!.isOpen) {
        _database = await _initDB('inventor_version_$version.db');
      } else {
        int currentVersion = await _database!.getVersion();

        if (currentVersion < int.parse(version)) {
          if (kDebugMode) {
            print(
              'Upgrading database from version $currentVersion to $version',
            );
          }

          await _database!.close();

          _database = await _initDB('inventor_version_$version.db');
        }
      }
    }
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();

    final String path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: int.parse(version),
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('Upgrading database from version $oldVersion to $newVersion');
    }
    /*
    ** This functionality was introduced in version 1.0.4 (DB version 7).
    ** It supports the implementation of soft delete, allowing records to be
    ** marked as inactive instead of being permanently removed.
    */
    if (oldVersion < 7 && newVersion >= 7) {
      await db.execute(
        'ALTER TABLE inventory ADD COLUMN is_deleted INTEGER DEFAULT 0',
      );
      if (kDebugMode) {
        print('Added is_deleted column to inventory table.');
      }
    }
    // Add other upgrade steps here based on oldVersion and newVersion
  }

  Future<String?> getCurrentDbPath() async {
    try {
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(
        documentsDirectory.path,
        'inventor_version_$version.db',
      );
      return path;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current DB path: $e");
      }
      return null;
    }
  }

  Future<bool> createBackup() async {
    try {
      final String? currentDbPath = await getCurrentDbPath();

      if (currentDbPath == null) {
        if (kDebugMode) {
          print('Could not get current database path for backup.');
        }
        return false;
      }

      final File currentDbFile = File(currentDbPath);

      if (!await currentDbFile.exists()) {
        if (kDebugMode) {
          print(
            'Source database file does not exist for backup: $currentDbPath',
          );
        }

        return false;
      }

      final String? backupDir = await getPath();

      if (backupDir == null) {
        if (kDebugMode) {
          print(
            'Could not get backup directory path using getPath(). Ensure permissions are granted and the path is valid.',
          );
        }
        return false;
      }

      final Directory backupDirectory = Directory(backupDir);

      try {
        if (!await backupDirectory.exists()) {
          await backupDirectory.create(recursive: true);
          if (kDebugMode) {
            print('Created backup directory: $backupDir');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error creating backup directory $backupDir: $e');
        }
        return false;
      }

      final String backupFilePath = join(
        backupDir,
        'backup_inventor_version_$version.db',
      );

      await currentDbFile.copy(backupFilePath);

      if (kDebugMode) {
        print('Database backup created successfully at $backupFilePath');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating database backup: $e');
      }

      return false;
    }
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

  Future<int> archiveInventory(String id) async {
    final db = await database;

    return await db.update(
      'inventory',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> recoverInventory(String id) async {
    final db = await database;

    return await db.update(
      'inventory',
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreAllInventories() async {
    final db = await database;

    return await db.update(
      'inventory',
      {'is_deleted': 0},
      where: 'is_deleted = ?',
      whereArgs: [1],
    );
  }

  Future<int> deleteInventory(String id) async {
    final db = await database;

    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllInventories() async {
    final db = await database;

    return await db.delete(
      'inventory',
      where: 'is_deleted = ?',
      whereArgs: [1],
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
      try {
        if (await currentDbFile.exists()) {
          await currentDbFile.delete();
        }
        await backupFile.copy(currentDbPath);
        if (kDebugMode) {
          print('Database replaced successfully from $backupFilePath');
        }
        response = true;
      } catch (e) {
        if (kDebugMode) {
          print('Error replacing database: $e');
        }
        response = false;
        throw Exception('Failed to replace database: $e');
      }
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
