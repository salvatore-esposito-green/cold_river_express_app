import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cold_river_express_app/database/db_helper.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;

  FileService._internal();

  final DBHelper _dbHelper = DBHelper();

  Future<String?> copyDatabaseToDownloads() async {
    final dbFile = await _getDatabaseFile();
    if (dbFile == null || !dbFile.existsSync()) return null;

    final directory = await getExternalStorageDirectory();
    if (directory == null) return null;

    final newPath = "${directory.path}/inventoryColdRiver.db";
    final newFile = File(newPath);

    await dbFile.copy(newPath);
    return newPath;
  }

  Future<bool> shareDatabase() async {
    final copiedFilePath = await copyDatabaseToDownloads();
    if (copiedFilePath == null) {
      if (kDebugMode) {
        print("Errore: impossibile copiare il database per la condivisione.");
      }
      return false;
    }

    try {
      final result = await Share.shareXFiles([XFile(copiedFilePath)]);

      if (result.status == ShareResultStatus.dismissed) {
        print('Did you not like the pictures?');
      }

      return result.status == ShareResultStatus.success;
    } catch (e) {
      if (kDebugMode) {
        print("Errore durante la condivisione del file: $e");
      }
      return false;
    }
  }

  Future<File?> _getDatabaseFile() async {
    final db = await _dbHelper.database;
    return File(db.path);
  }
}
