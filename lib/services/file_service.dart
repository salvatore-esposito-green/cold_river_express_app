import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/core/platform_factory.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;

  FileService._internal();

  final DatabaseServiceInterface _dbService =
      PlatformFactory.createDatabaseService();

  Future<String?> copyDatabaseToDownloads() async {
    if (kIsWeb) {
      if (kDebugMode) {
        print("Database copy not supported on web");
      }
      return null;
    }

    final dbPath = await _dbService.getCurrentDbPath();
    if (dbPath == null) return null;

    final dbFile = File(dbPath);
    if (!dbFile.existsSync()) return null;

    final directory = await _dbService.getCurrentDbPath();
    if (directory == null) return null;

    final newPath =
        "${directory}_copy_${DateTime.now().millisecondsSinceEpoch}.db";

    await dbFile.copy(newPath);
    return newPath;
  }

  Future<bool> shareDatabase() async {
    if (kIsWeb) {
      return await _dbService.createBackup();
    }

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
        if (kDebugMode) {
          print('Did you not like the pictures?');
        }
      }

      return result.status == ShareResultStatus.success;
    } catch (e) {
      if (kDebugMode) {
        print("Errore durante la condivisione del file: $e");
      }
      return false;
    }
  }

  Future<bool> importDatabase() async {
    if (kIsWeb) {
      // Su web, usa il metodo specifico restoreFromBackup
      // Nota: dobbiamo fare un cast al tipo concreto per accedere al metodo
      final dbService = _dbService;
      if (dbService.runtimeType.toString() == 'DatabaseServiceWeb') {
        // Usiamo dynamic per accedere al metodo specifico web
        try {
          return await (dbService as dynamic).restoreFromBackup();
        } catch (e) {
          if (kDebugMode) {
            print("Error importing database on web: $e");
          }
          return false;
        }
      }
      return false;
    }

    if (kDebugMode) {
      print("Database import not yet implemented on mobile");
    }
    return false;
  }
}
