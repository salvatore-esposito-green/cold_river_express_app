import 'dart:io';

import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> migrateCacheImagesAndUpdateDB() async {
  InventoryRepository inventoryRepository = InventoryRepository();

  final Directory cacheDir = await getTemporaryDirectory();
  final Directory documentsDir = await getApplicationDocumentsDirectory();

  final String newImagesPath = join(documentsDir.path, 'images_cold_river');

  final Directory permanentDir = Directory(newImagesPath);
  if (!await permanentDir.exists()) {
    await permanentDir.create(recursive: true);
  }

  final List<FileSystemEntity> files = cacheDir.listSync();

  for (var entity in files) {
    if (entity is File && entity.path.toLowerCase().endsWith('.jpg')) {
      final String fileName = basename(entity.path);
      final String newPath = join(permanentDir.path, fileName);

      try {
        await entity.copy(newPath);

        await inventoryRepository.updateImagePath(entity.path, newPath);

        if (kDebugMode) {
          print('Migrated ${entity.path} to $newPath');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error migrating file ${entity.path}: $e');
        }
      }
    }
  }
  if (kDebugMode) {
    print('Migration completed. Images are now stored in: $newImagesPath');
  }
}
